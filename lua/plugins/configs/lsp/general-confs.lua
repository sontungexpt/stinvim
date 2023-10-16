local lsp = vim.lsp

local M = {}

M.on_attach = function(client, bufnr)
	for _, case in ipairs { "Error", "Info", "Hint", "Warn" } do
		local hl = "DiagnosticSign" .. case
		vim.fn.sign_define(hl, {
			text = require("ui.icons.devicon")[hl],
			numhl = hl,
			texthl = hl,
		})
	end

	vim.diagnostic.config {
		virtual_text = {
			prefix = "●",
		},
		signs = true,
		underline = true,
		severity_sort = true,
		update_in_insert = false,
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
		virtual_text = {
			spacing = 5,
			severity_limit = "Warning",
			prefix = "●",
		},
		update_in_insert = true,
	})
end

M.capabilities = function(no_lspconfig)
	local capabilities = vim.tbl_deep_extend(
		"force",
		no_lspconfig and vim.lsp.protocol.make_client_capabilities()
			or require("lspconfig").util.default_config.capabilities
			or {},
		require("cmp_nvim_lsp").default_capabilities()
	)

	capabilities.offsetEncoding = { "utf-8", "utf-16" }
	capabilities.textDocument.completion.completionItem = {
		documentationFormat = { "markdown", "plaintext" },
		snippetSupport = true,
		preselectSupport = true,
		insertReplaceSupport = true,
		labelDetailsSupport = true,
		deprecatedSupport = true,
		commitCharactersSupport = true,
		tagSupport = { valueSet = { 1 } },
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

	return capabilities
end

return M
