local handler = function(virtText, lnum, endLnum, width, truncate)
	-- Avoid calling vim.fn.strdisplaywidth() multiple times for the same string.
	local suffix = ("  %d "):format(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth

	-- Create a table to store the truncated text.
	local newVirtText = {}

	-- Iterate over the virtText table, truncating each chunk as needed.
	local curWidth = 0
	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)

		if targetWidth > curWidth + chunkWidth then
			-- The chunk fits within the target width, so add it to the new table.
			table.insert(newVirtText, chunk)
			curWidth = curWidth + chunkWidth
		else
			-- The chunk does not fit within the target width, so truncate it and add
			-- it to the new table.
			chunkText = truncate(chunkText, targetWidth - curWidth)
			table.insert(newVirtText, { chunkText, chunk[2] })
			curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)

			-- If the truncated chunk is not the last chunk, add padding to the
			-- suffix.
			if curWidth < targetWidth then
				string.insert(suffix, " ", suffix:len() + 1)
			end
			break
		end
	end

	-- Add the suffix to the new table.
	table.insert(newVirtText, { suffix, "MoreMsg" })

	return newVirtText
end

local options = {
	open_fold_hl_timeout = 100,
	close_fold_kinds = { "imports", "comment" },
	preview = {
		win_config = {
			border = "single",
			winhighlight = "Normal:Folded",
			winblend = 0,
		},
		mappings = {
			scrollU = "<C-u>",
			scrollD = "<C-d>",
			jumpTop = "[",
			jumpBot = "]",
		},
	},
	provider_selector = function(_, filetype, buftype)
		local function handleFallbackException(bufnr, err, providerName)
			if type(err) == "string" and err:match("UfoFallbackException") then
				return require("ufo").getFolds(bufnr, providerName)
			else
				return require("promise").reject(err)
			end
		end

		-- only use indent until a file is opened
		return (filetype == "" or buftype == "nofile") and "indent"
			or function(bufnr)
				return require("ufo")
					.getFolds(bufnr, "lsp")
					:catch(function(err)
						return handleFallbackException(bufnr, err, "treesitter")
					end)
					:catch(function(err)
						return handleFallbackException(bufnr, err, "indent")
					end)
			end
	end,
	fold_virt_text_handler = handler,
}

return options
