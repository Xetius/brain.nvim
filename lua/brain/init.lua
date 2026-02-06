local ui = require("brain.ui")
local config = require("brain.config")
local throbber = require("brain.throbber")

local M = {}

-- Setup function for configuration
function M.setup(opts)
	config.setup(opts)
end

local function get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local start_line = start_pos[2]
	local end_line = end_pos[2]

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	return table.concat(lines, "\n"), start_line, end_line
end

function M.think()
	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
		vim.notify("Brain: Please select code in visual mode first", vim.log.levels.WARN)
		return
	end

	-- Get visual selection
	vim.cmd("normal! \27") -- Exit visual mode
	local code, start_line, end_line = get_visual_selection()

	ui.create_prompt_window(function(prompt)
		if not prompt or prompt:match("^%s*$") then
			vim.notify("Brain: No prompt provided", vim.log.levels.WARN)
			return
		end

		local selection = config.get_current_selection()
		local bufnr = vim.api.nvim_get_current_buf()

		-- Start the throbber
		throbber.start_throbber(bufnr, start_line, end_line)
		vim.notify(string.format("Brain: Thinking with %s...", selection.model), vim.log.levels.INFO)

		ui.call_ai(prompt, code, function(result)
			-- Stop the throbber
			throbber.stop_throbber(bufnr)

			-- Extract code from markdown code blocks if present
			result = result:gsub("^```%w*\n", ""):gsub("\n```$", ""):gsub("^```%w*", ""):gsub("```$", "")

			local lines = vim.split(result, "\n")

			vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)

			vim.notify("Brain: Done!", vim.log.levels.INFO)
		end)
	end)
end

-- Function to just change the model without thinking
function M.select_model()
	ui.select_model()
end

return M
