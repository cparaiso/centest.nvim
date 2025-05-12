-- Define a Neovim command to run a shell command and show output in a panel
vim.api.nvim_create_user_command("RunShellCmd", function(opts)
	require("centest.core").main()
end, { nargs = 1 })

-- Set keybinding for <leader>tt to run main with a specific command
vim.keymap.set("n", "<leader>tt", function()
	require("centest.core").main() -- Replace 'ls -la' with desired command
end, { noremap = true, silent = true, desc = "Run shell command in bottom panel" })
