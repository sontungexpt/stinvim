local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then return end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then return end

cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{
			name = "lazydev",
			group_index = 0, -- set group index to 0 to skip loading LuaLS completions
		},
		{ name = "luasnip", keyword_length = 4 },
		{ name = "path", keyword_length = 3 },
		{ name = "buffer", keyword_length = 3 },
		{ name = "copilot", keyword_length = 3 },
		{ name = "emoji", keyword_length = 3 },
		{ name = "dotenv", keyword_length = 3 },
		{ name = "nvim_lua", keyword_length = 3 },
	},
	window = {
		documentation = cmp.config.window.bordered(),
		-- completion = cmp.config.window.bordered(),
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			vim_item.kind = require("ui.icons.lspkind")[vim_item.kind]
			local color_item = require("nvim-highlight-colors").format(entry, { kind = vim_item.kind })
			if color_item.abbr_hl_group then
				vim_item.kind_hl_group = color_item.abbr_hl_group
				vim_item.kind = color_item.abbr
			end
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
		["<C-Space>"] = cmp.mapping.complete(),
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
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sorting = {
		priority_weight = 2,
	},
}
