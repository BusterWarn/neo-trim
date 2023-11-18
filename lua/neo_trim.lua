local M = {}

M.ns = vim.api.nvim_create_namespace('neo-trim')

-- The diagnostic function that would be called on events like BufWrite, BufEnter, etc.
function M.show_trailing_whitespace()
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
        severity = vim.diagnostic.severity.WARN,
      })
    end
  end

  vim.diagnostic.set(M.ns, 0, diagnostics, {})
end

-- Function to trim trailing whitespace
function M.trim_trailing_whitespace()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i, line in ipairs(lines) do
    local trimmed_line = line:gsub("%s+$", "")
    if trimmed_line ~= line then
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, {trimmed_line})
    end
  end
end

-- Autocommand to trim whitespace before saving a file
function M.setup_autocommands()
  print("M.setup_autocommands")

  vim.api.nvim_create_autocmd({"BufWrite", "BufEnter", "TextChanged", "InsertLeave"}, {
    pattern = "*",
    callback = M.trim_trailing_whitespace
  })

  -- -- Command to trim whitespace
  vim.api.nvim_create_user_command('TrimWhitespace', M.trim_trailing_whitespace, {})
  -- Configure the signs
  vim.fn.sign_define("DiagnosticSignWarn", {text = "H", texthl = "DiagnosticSignWarn"})

  -- Apply the squiggly underline highlight
  vim.cmd([[highlight DiagnosticUnderlineWarn gui=undercurl guisp=Purple]])
end

-- Setup function that users can call to initialize the plugin
function M.setup()
  print("M.setup()")
  M.setup_autocommands()
end

-- Return the module table
return M
