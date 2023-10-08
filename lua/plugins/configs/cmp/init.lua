local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then return end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then return end

local check_backspace = function()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	sources = {
		{ name = "path" },
		{ name = "nvim_lsp", keyword_length = 1 },
		{ name = "buffer", keyword_length = 3 },
		{ name = "luasnip", keyword_length = 4 },
		{ name = "nvim_lua", keyword_length = 2 },
		{ name = "copilot", keyword_length = 3 },
		{ name = "emoji", keyword_length = 2 },
	},
	window = {
		documentation = cmp.config.window.bordered(),
		-- border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
		border = "single",
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		--fields = {'menu', 'abbr', 'kind'},
		format = function(entry, vim_item)
			-- Kind icons
			vim_item.kind = string.format("%s", require("plugins.configs.cmp.kind-icons")[vim_item.kind])
			-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
			-- This concatenates the icons with the name of the item kind
			vim_item.menu = ({
				nvim_lsp = "λ ",
				luasnip = " ",
				buffer = "Ω ",
				path = "󱘎 ",
				nvim_lua = " ",
				copilot = " ",
				Copilot = " ",
			})[entry.source.name]
			return vim_item
		end,
	},
	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Selected,
		select = false,
	},
	experimental = {
		ghost_text = false,
		native_menu = false,
	},
	mapping = {
		["<Up>"] = cmp.mapping.select_prev_item(),
		["<Down>"] = cmp.mapping.select_next_item(),
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<CR>"] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Insert, select = true },
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				vim.fn.feedkeys(
					vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true),
					""
				)
			elseif check_backspace() then
				fallback()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sorting = {
		priority_weight = 2,
	},
}
