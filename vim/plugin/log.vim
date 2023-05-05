let s:type = { "ERROR" : "logErrorStatement", "WARN" : "logWarnStatement", "INFO" : "logInfoStatement", "DEBUG" : "logDebugStatement" }

function! SetLevelColor(level, line, lineno)
    let index = stridx(a:line, a:level) + 1
    let levelLen = strlen(a:level)
    if index >= 1
        call prop_add(a:lineno, index, {"length" : levelLen, "type" : "logLevel"})
        if index - 1 > 1
        	call prop_add(a:lineno, 1, {"length" : index - 1, "type" : s:type[a:level]})
        endif
        call prop_add(a:lineno, index + levelLen, {"length" : strlen(a:line) - levelLen - index + 1, "type" : s:type[a:level]})
    endif
endfunction

function! SetLogColor()
    hi clear
	hi Normal ctermfg=white ctermbg=black guibg=black guifg=white

    call hlset([{"name" : "logLevel", "ctermfg" : "Blue", "guifg" : "Blue"}])
    call hlset([{"name" : "logErrorStatement", "ctermfg" : "Red", "guifg" : "Red"}])
    call hlset([{"name" : "logWarnStatement", "ctermfg" : "Yellow", "guifg" : "Yellow"}])
    call hlset([{"name" : "logInfoStatement", "ctermfg" : "White", "guifg" : "White"}])
    call hlset([{"name" : "logDebugStatement", "ctermfg" : "Green",  "guifg" : "Green"}])

	if prop_type_get("logLevel")->len() <= 0
   		call prop_type_add("logLevel", {"highlight" : "logLevel"})
   		call prop_type_add("logErrorStatement", {"highlight" : "logErrorStatement"})
   		call prop_type_add("logWarnStatement", {"highlight" : "logWarnStatement"})
   		call prop_type_add("logInfoStatement", {"highlight" : "logInfoStatement"})
   		call prop_type_add("logDebugStatement", {"highlight" : "logDebugStatement"})
    endif

    let lines = getline(1, line("$"))
    let lineno = 1
    for line in lines
        call SetLevelColor("ERROR", line, lineno)
        call SetLevelColor("WARN", line, lineno)
        call SetLevelColor("INFO", line, lineno)
        call SetLevelColor("DEBUG", line, lineno)
        let lineno = lineno + 1
    endfor
endfunction

au BufRead,BufNewFile *.log call SetLogColor()
