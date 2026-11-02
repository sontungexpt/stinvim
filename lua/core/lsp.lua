-- ------------------------------------------------------------ LSP Capabilities ------------------------------------------------------------
-- Builds the default client capabilities advertised to all language servers.
-- Extends vim.lsp.protocol.make_client_capabilities() only where we need
-- richer support than the base defaults provide.

local M = {}

--- Create the default set of LSP client capabilities.
--- These are merged into every server config via `vim.lsp.config("*", ...)`.
--- @return table capabilities # A complete vim.lsp.Client capabilities table
function M.make_default_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Completion: enable snippets and resolve support
  capabilities.textDocument.completion.completionItem = {
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    documentationFormat = { "markdown", "plaintext" },
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
      properties = { "documentation", "detail", "additionalTextEdits" },
    },
  }

  -- Folding range: line folding only
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  -- Workspace file operations: enable rename/create/delete tracking
  capabilities.workspace.fileOperations = {
    didRename = true,
    willRename = true,
    didCreate = true,
    willCreate = true,
    didDelete = true,
    willDelete = true,
  }

  return capabilities
end

--- Configure vim.diagnostic with the project's default appearance.
function M.setup_diagnostics()
  local icons = require("ui.icons")
  vim.diagnostic.config({
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.DiagnosticSign.Error,
        [vim.diagnostic.severity.WARN] = icons.DiagnosticSign.Warn,
        [vim.diagnostic.severity.HINT] = icons.DiagnosticSign.Hint,
        [vim.diagnostic.severity.INFO] = icons.DiagnosticSign.Info,
      },
    },
    virtual_text = {
      spacing = 4,
      source = "if_many",
      prefix = "●",
    },
    float = {
      source = "if_many",
      border = "single",
    },
  })
end


return M
