local M = {}

M.ns = vim.api.nvim_create_namespace("neo-trim")

M.config = {
	trim_command_name = "TrimWhitespace",
	auto_trim_on_write = true,
	exclude_diagnostics_for_languages = {},
	exclude_auto_trimming_for_languages = {},
}

--- Checks if a given filetype is in the provided exclusion list.
-- @param filetype The filetype to check.
-- @param exclude_list The list of filetypes to exclude.
-- @return `true` if the filetype is in the exclude list, `false` otherwise.
local function is_excluded(filetype, exclude_list)
	for _, ft in ipairs(exclude_list) do
		if ft == filetype then
			return true
		end
	end
	return false
end

local function is_saved_file()
	local bufnr = vim.api.nvim_get_current_buf()
	local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
	local filepath = vim.api.nvim_buf_get_name(bufnr)

	return buftype == "" and filepath ~= "" and vim.loop.fs_stat(filepath) ~= nil
end

function M.show_trailing_whitespace()
	if not is_saved_file() or is_excluded(vim.bo.filetype, M.config.exclude_diagnostics_for_languages) then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local diagnostics = {}

	for i, line in ipairs(lines) do
		local s, e = string.find(line, "%s+$")
		if s then
			table.insert(diagnostics, {
				lnum = i - 1,
				col = s - 1,
				end_col = e,
				message = "Trailing whitespace",
				severity = vim.diagnostic.severity.HINT,
			})
		end
	end

	vim.diagnostic.set(M.ns, 0, diagnostics, {})
end

function M.trim_trailing_whitespace()
	if not is_saved_file() or is_excluded(vim.bo.filetype, M.config.exclude_auto_trimming_for_languages) then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for i, line in ipairs(lines) do
		local trimmed_line = line:gsub("%s+$", "")
		if trimmed_line ~= line then
			vim.api.nvim_buf_set_lines(0, i - 1, i, false, { trimmed_line })
		end
	end
end

local function setup_diagnostics()
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "TextChanged", "InsertLeave" }, {
		pattern = "*",
		callback = M.show_trailing_whitespace,
	})
end

local function setup_user_command(trim_command_name)
	if trim_command_name == "" then
		return
	end
	vim.api.nvim_create_user_command(trim_command_name, M.trim_trailing_whitespace, {})
end

local function setup_auto_trimming()
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		callback = function()
			if is_saved_file() then
				M.trim_trailing_whitespace()
			end
		end,
	})
end

function M.setup(user_config)
	user_config = user_config or {}
	M.config = vim.tbl_extend("force", M.config, user_config)

	setup_diagnostics()
	setup_user_command(M.config.trim_command_name)

	if M.config.auto_trim_on_write then
		setup_auto_trimming()
	end
end

return M
