local M = {}

local lsp = vim.lsp
local handlers = lsp.handlers

local signs_hl = {
	"DiagnosticSignError",
	"DiagnosticSignWarn",
	"DiagnosticSignHint",
	"DiagnosticSignInfo",
}

vim.diagnostic.config {
	signs = {
		text = require("ui.icons").DiagnosticSign,
		numhl = signs_hl,
		texthl = signs_hl,
	},
	underline = true,
	severity_sort = true,
	update_in_insert = true,
	virtual_text = false,
	float = {
		source = "if_many",
	},
}

handlers["textDocument/signatureHelp"] = lsp.with(handlers.signature_help, {
	border = "single",
	focusable = false,
	relative = "cursor",
})

handlers["textDocument/hover"] = lsp.with(handlers.hover, {
	border = "single",
})

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

M.on_attach = function(client, bufnr)
	require("better-diagnostic-virtual-text.api").setup_buf(bufnr, {
		inline = true,
		ui = { above = true },
	})
end
M.capabilities = capabilities

return M
