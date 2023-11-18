local fn = vim.fn
local M = {}

M.lang = {
	["rust"] = {
		cmd = "cargo build",
		msg = {
			running = "cargo build running",
			succeed = "cargo build success",
			failed = "cargo build failed",
			timed_out = "cargo build timed out",
		},
		timeout = 2000,
	},
}

M.continue_debugging = function()
	vim.schedule(function()
		local lang = M.lang[vim.bo.filetype]
		if not lang then
			require("utils.notify").error(
				string.format(
					"No language config found for %s. Config for language in lua/plugins/configs/dap/utils.lua",
					vim.bo.filetype
				),
				{ title = "Dap continue error" }
			)
			require("dap").continue()
			return
		end

		local job_id = fn.jobstart(lang.cmd)

		local timeout = lang.timeout or 2000

		local start_time = vim.loop.hrtime()
		while true do
			local status = fn.jobwait({ job_id }, timeout)[1]

			if status == 0 then
				require("utils.notify").info(lang.msg.succeed or "job succeed")
				require("dap").continue()
				break
			elseif status == -1 then
				-- Job was stopped (e.g. user cancelled the debugging session)
				fn.jobstop(job_id)
				require("utils.notify").error("job stopped suddenly", { title = "Dap continue error" })
				break
			else
				-- Job failed to start or encountered an error
				fn.jobstop(job_id)
				require("utils.notify").error(lang.msg.failed, { title = "Dap continue error" })
				break
			end

			local elapsed_time = vim.loop.hrtime() - start_time
			if elapsed_time / 1e6 >= timeout then
				-- Job timed out
				fn.jobstop(job_id)
				require("utils.notify").error(lang.msg.timed_out, { title = "Dap continue error" })
				break
			end
		end
	end)
end

return M
