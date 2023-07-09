local function str_find(s, pattern)
    local ret = false
    local b, e = string.find(s, pattern)
    if s ~= nil and e ~= nil then
        ret = true
    end
    return ret
end

function highlight_log()
    local content = vim.fn.getline(1, '$')
    local ns_id = vim.api.nvim_create_namespace("log")
    for line_no, line in ipairs(content) do
        if str_find(line, "DEBUG") then
            -- create the highlight through an extmark
            extid = vim.api.nvim_buf_set_extmark(0, ns_id, line_no - 1, 0, {end_col = string.len(line), hl_group = "DiagnosticOk"})
        elseif str_find(line, "ERR") then 
            -- create the highlight through an extmark
            extid = vim.api.nvim_buf_set_extmark(0, ns_id, line_no - 1, 0, {end_col = string.len(line), hl_group = "ErrorMsg"})
        elseif str_find(line, "WARN") then 
            -- create the highlight through an extmark
            extid = vim.api.nvim_buf_set_extmark(0, ns_id, line_no - 1, 0, {end_col = string.len(line), hl_group = "DiagnosticWarn"})
        elseif str_find(line, "INFO") then 
            -- create the highlight through an extmark
            extid = vim.api.nvim_buf_set_extmark(0, ns_id, line_no - 1, 0, {end_col = string.len(line), hl_group = "Normal"})
        end
    end
end


