local M = {}

M.config = {
	plugin_on = false,
	command_by_ft = {
		["go"] = "go test -v",
	},
}

function M.setup(opts)
	opts = opts or {}
	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function()
			-- empty
		end,
	})
	require("centest.core").init(M.config)
end

return M
