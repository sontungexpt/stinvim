local options = {
	-- open_fold_hl_timeout = 400,
	close_fold_kinds_for_ft = {
		default = { "imports", "comment" },
		json = { "array" },
		c = { "comment", "region" },
	},
	preview = {
		win_config = {
			border = "single",
			winhighlight = "Normal:NormalFloat",
			-- winhighlight = "Normal:Folded",
			winblend = 0,
		},
		mappings = {
			scrollE = "<C-E>",
			scrollY = "<C-Y>",
			scrollU = "<C-u>",
			scrollD = "<C-d>",
			jumpTop = "gg",
			jumpBot = "G",
		},
	},
	provider_selector = function(_, filetype, buftype)
		-- only use indent until a file is opened
		if filetype == "" or buftype == "nofile" then return "indent" end

		return function(bufnr)
			local ufo = require("ufo")
			local function handleFallbackException(err, providerName)
				if type(err) == "string" and err:match("UfoFallbackException") then
					return ufo.getFolds(bufnr, providerName)
				else
					return require("promise").reject(err)
				end
			end
			return ufo
				.getFolds(bufnr, "lsp")
				:catch(function(err) return handleFallbackException(err, "treesitter") end)
				:catch(function(err) return handleFallbackException(err, "indent") end)
		end
	end,
	fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
		local suffix = ("  %d "):format(endLnum - lnum)
		local sufWidth = vim.fn.strdisplaywidth(suffix)
		local targetWidth = width - sufWidth
		local newVirtText = {}
		local curWidth = 0
		for _, chunk in ipairs(virtText) do
			local chunkText = chunk[1]
			local chunkWidth = vim.fn.strdisplaywidth(chunkText)

			if targetWidth > curWidth + chunkWidth then
				-- The chunk fits within the target width, so add it to the new table.
				table.insert(newVirtText, chunk)
				curWidth = curWidth + chunkWidth
			else
				chunkText = truncate(chunkText, targetWidth - curWidth)
				table.insert(newVirtText, { chunkText, chunk[2] })
				curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
				if curWidth < targetWidth then string.insert(suffix, " ", suffix:len() + 1) end
				break
			end
		end
		table.insert(newVirtText, { suffix, "MoreMsg" })
		return newVirtText
	end,
}

return options
