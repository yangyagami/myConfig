local options = {
	shiftwidth = 4,
	tabstop = 4,
	expandtab = true,
    relativenumber = true,
    termguicolors = true,
    cursorline = true
}

for k, v in pairs(options) do
	vim.opt[k] = v
end
