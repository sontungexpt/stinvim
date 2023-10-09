local colors = require("core.global-configs").ui.colors

local lsp_servers = function()
	if vim.o.columns > 70 then
		local buf_clients = vim.lsp.buf_get_clients()

		if not buf_clients or #buf_clients == 0 then
			return "NO LSP  "
		end

		local server_names = {}

		for _, client in pairs(buf_clients) do
			local client_name = client.name
			if client_name ~= "null-ls" and client_name ~= "copilot" then
				table.insert(server_names, client_name)
			end
		end

		if package.loaded["null-ls"] then
			local has_null_ls, null_ls = pcall(require, "null-ls")

			if has_null_ls then
				local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
				local null_ls_methods = {
					null_ls.methods.DIAGNOSTICS,
					null_ls.methods.DIAGNOSTICS_ON_OPEN,
					null_ls.methods.DIAGNOSTICS_ON_SAVE,
					null_ls.methods.FORMATTING,
				}

				local get_null_ls_sources = function(methods, name_only)
					local sources = require("null-ls.sources")
					local available_sources = sources.get_available(buf_ft)

					methods = type(methods) == "table" and methods or { methods }

					-- methods = nil or {}
					if #methods == 0 then
						if name_only then
							return vim.tbl_map(function(source)
								return source.name
							end, available_sources)
						end
						return available_sources
					end

					local source_results = {}

					for _, source in ipairs(available_sources) do
						for _, method in ipairs(methods) do
							if source.methods[method] then
								if name_only then
									table.insert(source_results, source.name)
								else
									table.insert(source_results, source)
								end
								break
							end
						end
					end

					return source_results
				end

				local null_ls_builtins = get_null_ls_sources(null_ls_methods, true)
				vim.list_extend(server_names, null_ls_builtins)
			end
		end
		return table.concat(server_names, ", ")
	end
	return ""
end

return {
	lsp_servers,
	color = { fg = colors.magenta },
}
