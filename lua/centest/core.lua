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
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_set_option_value("number", false, { win = M.config.output_win })
	vim.api.nvim_set_option_value("relativenumber", false, { win = M.config.output_win })
end

local function execute_tests() end
local function close_tests() end

function M.init(config)
	M.config = config
	-- this is wired up! lets goooooo
end

function M.main(args)
	if M.config.plugin_on == true then
		close_window(M.config.output_win)
		M.config.plugin_on = false
		return
	end

	M.config.plugin_on = true
	M.config.output_win = render_window()

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(M.config.output_win, buf)
	set_buffer_opts()

	local output = {}
	vim.fn.jobstart(M.config.command_by_ft["go"], {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(output, line)
					end
				end
			end
		end,
		on_stderr = function(_, data)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(output, line)
					end
				end
			end
		end,
		on_exit = function()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
			vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
			vim.api.nvim_set_option_value("modified", false, { buf = buf })
		end,
	})
end

return M
