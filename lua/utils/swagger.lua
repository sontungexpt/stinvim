local uv = vim.uv or vim.loop
local SWAGGER_URL = "http://localhost:8080/swagger-ui/index.html"
local open_swagger_server = false

local reload_swagger_timer = uv.new_timer()

local get_debug_url = function(key, callback)
	vim.schedule(function()
		local find_tab_cmd = [[curl -s http://localhost:9222/json | jq -r --arg TARGET_URL "]]
			.. SWAGGER_URL
			.. [[" '.[] | select(.url == $TARGET_URL) | .]]
			.. key
			.. [[']] -- local debug_url = vim.fn.system(find_tab_cmd):gsub("%s+", "")
		vim.fn.jobstart(find_tab_cmd, {
			on_stdout = function(_, url, _)
				vim.notify(vim.inspect(url))
				callback(url)
			end,
		})
	end)
end

local start_swagger_server = function()
	get_debug_url("webSocketDebuggerUrl", function(url)
		reload_swagger_timer:start(0, 1500, function()
			open_swagger_server = true
			if url == "" then
				require("utils.notify").warn("Swagger preview not found!")
				return
			end
			vim.system({ "curl", "-s", "-X", "POST", "-d", '{"id":1,"method":"Page.reload"}', url }, {}, function() end)
		end)
	end)
end

vim.api.nvim_create_user_command("SwaggerPreviewStart", function()
	local browser = "microsoft-edge-stable"

	if not open_swagger_server then
		vim.system({
			browser,
			"--remote-debugging-address=127.0.0.1",
			"--remote-debugging-port=9222-open",
			SWAGGER_URL,
		}, {}, function()
			vim.defer_fn(function() start_swagger_server() end, 300)
		end)
	end
end, { nargs = 0 })

vim.api.nvim_create_user_command("SwaggerPreviewStop", function()
	reload_swagger_timer:stop()
	get_debug_url("id", function(url)
		if url == "" then
			require("utils.notify").warn("Swagger preview not found!")
			return
		end
		vim.system({ "curl", "-s", "-X", "POST", "-d", '{"id":1,"method":"Page.close"}', url }, {}, function() end)
	end)
	open_swagger_server = false
end, { nargs = 0 })
vim.api.nvim_create_user_command("SwaggerPreviewToggle", function()
	if open_swagger_server then
		vim.api.nvim_command("SwaggerPreviewStop")
	else
		vim.api.nvim_command("SwaggerPreviewStart")
	end
end, { nargs = 0 })
