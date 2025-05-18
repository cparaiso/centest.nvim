local M = {}
local core = require("centest.core")
function M.init(state)
	vim.api.nvim_create_user_command("CentestRun", function()
		core.main(nil)
	end, { nargs = 1 })

	vim.keymap.set("n", "<leader>tt", function()
		core.main(nil)
	end, { noremap = true, silent = true, desc = "Run shell command in bottom panel" })

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("CentestGroup", { clear = true }),
		pattern = "*",
		callback = function()
			vim.notify(state.output_win)
			if state.window_open and state.output_win ~= nil then
				core.execute_command()
			end
		end,
	})
end

return M
