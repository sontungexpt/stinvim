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
-- local fn = vim.fn
-- local M = {}

-- -- the commands should be run before start debugging
-- M.initial_jobs = {
-- 	rust = {
-- 		{
-- 			async = false,
-- 			priority = 10, -- only work when async = false
-- 			cmd = { "cargo", "build" },
-- 			opts = nil,
-- 			-- the max time to wait for the command
-- 			timeout = 2000,
-- 			-- the message to show when the command finish
-- 			msg = {
-- 				running = "cargo build running",
-- 				succeed = "cargo build success",
-- 				failed = "cargo build failed",
-- 				timed_out = "cargo build timed out",
-- 			},
-- 		},
-- 		{
-- 			async = false,
-- 			priority = 11, -- only work when async = false
-- 			cmd = { "echo", "build" },
-- 			opts = nil,
-- 			-- the max time to wait for the command
-- 			timeout = 2000,
-- 			-- the message to show when the command finish
-- 			msg = {
-- 				running = "cargo build running",
-- 				succeed = "cargo build success",
-- 				failed = "cargo build failed",
-- 				timed_out = "cargo build timed out",
-- 			},
-- 		},
-- 	},
-- }

-- local get_cmd_str = function(cmd)
-- 	if type(cmd) == "string" then
-- 		return cmd
-- 	elseif type(cmd) == "table" then
-- 		return table.concat(cmd, " ")
-- 	else
-- 		return tostring(cmd)
-- 	end
-- end

-- M.continue_debugging = function()
-- 	vim.schedule(function()
-- 		local filetype = vim.api.nvim_buf_get_option(0, "filetype")
-- 		local jobs = M.initial_jobs[filetype]

-- 		if type(jobs) ~= "table" or next(jobs) == nil then
-- 			require("dap").continue()
-- 			return
-- 		end

-- 		require("dap").continue()
-- 		-- local done = false
-- 		-- local timeout = 1000

-- 		-- local job_runned_ids = {}
-- 		-- local job_queue = {}

-- 		-- for _, job in ipairs(jobs) do
-- 		-- 	if type(job) == "table" then
-- 		-- 		if job.async ~= false then
-- 		-- 			table.insert(job_queue, fn.jobstart(job.cmd, job.opts))
-- 		-- 		else
-- 		-- 			print("async is false")
-- 		-- 			table.insert(job_queue, job)
-- 		-- 		end
-- 		-- 	end
-- 		-- end

-- 		-- -- 		for index, status in ipairs(fn.jobwait(job_ids, timeout)) do
-- 		-- -- 			if status == 0 then
-- 		-- -- 				require("utils.notify").info(jobs.msg.succeed or "job succeed")
-- 		-- -- 				require("dap").continue()
-- 		-- -- 			elseif status == -1 then
-- 		-- -- 				-- the timeout was exceeded
-- 		-- -- 				local command_index = job_id_cmd_index_maps[index]
-- 		-- -- 				local command_str = type(command_index.cmd) == "table" and table.concat(command_index.cmd, " ")
-- 		-- -- 					or command_index.cmd
-- 		-- -- 				require("utils.notify").error(
-- 		-- -- 					"job meet time out for command: " .. command_str,
-- 		-- -- 					{ title = "Dap continue error" }
-- 		-- -- 				)
-- 		-- -- 				return
-- 		-- -- 			elseif status == -2 then
-- 		-- -- 				-- the job was interrupted (by |CTRL-C|)
-- 		-- -- 				require("utils.notify").error(jobs.msg.failed, { title = "Dap continue error" })
-- 		-- -- 			elseif status == -3 then
-- 		-- -- 				-- the job-id is invalid
-- 		-- -- 				require("utils.notify").error(jobs.msg.failed, { title = "Dap continue error" })
-- 		-- -- 			end
-- 		-- -- 		end

-- 		-- -- after handle all async jobs then handle sync jobs
-- 		-- local function sync_job(key)
-- 		-- 	local job = nil
-- 		-- 	key, job = next(job_queue, key)
-- 		-- 	if key then
-- 		-- 		local opts = type(job.opts) == "table" and job.opts or {}
-- 		-- 		local on_exit = opts.on_exit
-- 		-- 		opts.on_exit = function(_, code, ...)
-- 		-- 			if type(on_exit) == "function" then on_exit(_, code, ...) end
-- 		-- 			if code == 0 then
-- 		-- 				require("utils.notify").info(job.msg.succeed or get_cmd_str(job.cmd) .. " succeed")
-- 		-- 				sync_job(key)
-- 		-- 			else
-- 		-- 				require("utils.notify").error(job.msg.failed or get_cmd_str(job.cmd) .. " failed")
-- 		-- 			end
-- 		-- 		end
-- 		-- 		require("utils.notify").info(job.msg.running or get_cmd_str(job.cmd) .. " running")
-- 		-- 		fn.jobstart(job.cmd, opts)
-- 		-- 	else
-- 		-- 		-- all jobs is done
-- 		-- 		require("dap").continue()
-- 		-- 	end
-- 		-- end

-- 		-- table.sort(job_queue, function(a, b) return (a.priority or 0) > (b.priority or 0) end)
-- 		-- sync_job(nil)
-- 	end)
-- end

-- return M
