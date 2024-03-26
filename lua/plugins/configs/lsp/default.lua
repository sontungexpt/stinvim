local lsp = vim.lsp

local M = {}

M.on_attach = function(client, bufnr)
	for _, case in ipairs { "Error", "Info", "Hint", "Warn" } do
		local hl = "DiagnosticSign" .. case
		vim.fn.sign_define(hl, {
			text = require("ui.icons")[hl],
			numhl = hl,
			texthl = hl,
		})
	end

	vim.diagnostic.config {
		signs = true,
		underline = true,
		severity_sort = true,
		update_in_insert = false,
		virtual_text = {
			prefix = "●",
		},
		float = {
			source = "always",
		},
	}

	lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {
		border = "single",
		focusable = false,
		relative = "cursor",
	})

	lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, { border = "single" })

	lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
		signs = true,
		underline = true,
		update_in_insert = true,
		virtual_text = {
			prefix = "●",
			spacing = 4,
			severity_limit = "Warning",
		},
	})
end

local capabilities = lsp.protocol.make_client_capabilities()
	or require("lspconfig").util.default_config.capabilities
	or require("cmp_nvim_lsp").default_capabilities()

capabilities.textDocument.completion.completionItem = {
	snippetSupport = true,
	preselectSupport = true,
	insertReplaceSupport = true,
	labelDetailsSupport = true,
	deprecatedSupport = true,
	commitCharactersSupport = true,
	documentationFormat = {
		"markdown",
		"plaintext",
	},
	tagSupport = {
		valueSet = { 1 },
	},
	resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	},
}

-- for nvim-ufo
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

M.capabilities = capabilities

return M
