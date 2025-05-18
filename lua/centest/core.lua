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
		cwd = nil,
	}
	require("centest.mappings").init(M.state)
end

function M.execute_command()
	vim.api.nvim_set_option_value("modifiable", true, { buf = M.state.buf })
	vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, {})
	local original_cwd = vim.fn.getcwd()
	vim.fn.chdir(M.state.cwd)
	local output = vim.fn.system(M.config.command_by_ft["go"])
	local lines = vim.split(output, "\n", { trimempty = true })
	vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = M.state.buf })
	vim.api.nvim_set_option_value("modified", false, { buf = M.state.buf })
	vim.fn.chdir(original_cwd)
end

function M.main(_)
	if M.state.window_open == true then
		close_window(M.state.output_win)
		M.state.window_open = false
		return
	end

	M.state.cwd = vim.fn.expand("%:p:h")
	M.state.output_win = render_window()
	M.state.window_open = true
	M.state.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(M.state.output_win, M.state.buf)
	set_buffer_opts()
	M.execute_command()
end

return M
