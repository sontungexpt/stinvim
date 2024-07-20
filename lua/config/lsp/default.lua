local M = {}

local lsp = vim.lsp

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

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {
	border = "single",
	focusable = false,
	relative = "cursor",
})

lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, { border = "single" })

M.on_attach = function(client, bufnr)
	require("better-diagnostic-virtual-text.api").setup_buf(bufnr, {
		inline = true,
		ui = { above = true },
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
