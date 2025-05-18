local M = {}

local function render_window()
	vim.cmd("belowright split")
	local output_window = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_height(output_window, 15)
	return output_window
end

local function close_window(win)
	vim.api.nvim_win_close(win, true)
end

local function set_buffer_opts(buf)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("number", false, { win = M.config.output_win })
	vim.api.nvim_set_option_value("relativenumber", false, { win = M.config.output_win })
	vim.api.nvim_set_option_value("wrap", true, { buf = buf })
end

function M.init(config)
	M.config = config
	M.state = {
		window_open = false,
		output_win = nil,
		buf = nil,
	}
	require("centest.mappings").init(M.state)
end

function M.execute_command()
	vim.notify("foo: " .. vim.fn.expand("%:p:h"))
	vim.api.nvim_set_option_value("modifiable", true, { buf = M.state.buf })
	vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, {})
	-- Get the directory of the current buffer
	local buf_dir = vim.fn.expand("%:p:h")

	-- Save current working directory to restore later
	local original_cwd = vim.fn.getcwd()

	-- Change to the buffer's directory
	vim.fn.chdir(buf_dir)

	local output = vim.fn.system(M.config.command_by_ft["go"])
	-- Split output into lines
	local lines = vim.split(output, "\n", { trimempty = true })
	vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = M.state.buf })
	vim.api.nvim_set_option_value("modified", false, { buf = M.state.buf })
	-- Restore original working directory
	vim.fn.chdir(original_cwd)
	-- local output = {}
	-- vim.fn.jobstart(M.config.command_by_ft["go"], {
	-- 	cwd = vim.fn.expand("%:p:h"),
	-- 	stdout_buffered = true,
	-- 	on_stdout = function(_, data)
	-- 		if data then
	-- 			for _, line in ipairs(data) do
	-- 				if line ~= "" then
	-- 					table.insert(output, line)
	-- 				end
	-- 			end
	-- 		end
	-- 	end,
	-- 	on_stderr = function(_, data)
	-- 		if data then
	-- 			for _, line in ipairs(data) do
	-- 				if line ~= "" then
	-- 					table.insert(output, line)
	-- 				end
	-- 			end
	-- 		end
	-- 	end,
	-- 	on_exit = function()
	-- 		vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, output)
	-- 		vim.api.nvim_set_option_value("modifiable", false, { buf = M.state.buf })
	-- 		vim.api.nvim_set_option_value("modified", false, { buf = M.state.buf })
	-- 	end,
	-- })
end
function M.main(_)
	if M.state.window_open == true then
		close_window(M.state.output_win)
		M.state.window_open = false
		return
	end

	M.state.output_win = render_window()
	M.state.window_open = true
	M.state.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(M.state.output_win, M.state.buf)
	set_buffer_opts()
	M.execute_command()
end

return M
