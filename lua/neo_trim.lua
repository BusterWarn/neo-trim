local M = {}

M.ns = vim.api.nvim_create_namespace('neo-trim')

M.config = {
    trim_command_name = "TrimWhitespace",
    auto_trim_on_write = true,
    exclude_diagnostics_for_languages = {},
    exclude_auto_trimming_for_languages = {},
}

local function is_excluded(filetype, exclude_list)
  for _, ft in ipairs(exclude_list) do
    if ft == filetype then
      return true
    end
  end
  return false
end

function M.show_trailing_whitespace()
  if is_excluded(vim.bo.filetype, M.config.exclude_diagnostics_for_languages) then
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
        message = 'Trailing whitespace',
        severity = vim.diagnostic.severity.HINT,
      })
    end
  end

  vim.diagnostic.set(M.ns, 0, diagnostics, {})
end

function M.trim_trailing_whitespace()
  if is_excluded(vim.bo.filetype, M.config.exclude_auto_trimming_for_languages) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i, line in ipairs(lines) do
    local trimmed_line = line:gsub("%s+$", "")
    if trimmed_line ~= line then
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, {trimmed_line})
    end
  end
end

local function setup_diagnostics()
  vim.api.nvim_create_autocmd({"BufWrite", "BufEnter", "TextChanged", "InsertLeave"}, {
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
    callback = M.trim_trailing_whitespace
  })
end

function M.setup(user_config)
  M.config = vim.tbl_extend("force", M.config, user_config or {})

  setup_diagnostics()
  setup_user_command(M.config.trim_command_name)

  if M.config.auto_trim_on_write then
    setup_auto_trimming()
  end
end

return M
