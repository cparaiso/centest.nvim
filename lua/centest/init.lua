local M = {}

M.config = {
	command_by_ft = {
		["go"] = "go test -v",
	},
}

function M.setup(opts)
	opts = opts or {}
	require("centest.core").init(M.config)
end

return M
