local vim = vim
local api = vim.api

local M = {}

-- ---------------------------------------------------------------------------
-- Buffer
-- ---------------------------------------------------------------------------

--- Close a buffer matching the specified filetypes or buftypes.
---
--- @param bufnr number The buffer number to close.
--- @param matches string|table The filetypes or buffer types to close.
--- @param condition_name string|nil Can be "filetype" or "buftype" (default: "filetype").
function M.close_buffer_matching(bufnr, matches, condition_name)
    vim.schedule(function()
        local condition = api.nvim_get_option_value(condition_name or "filetype", { buf = bufnr })
        if type(matches) == "string" and condition == matches then
            api.nvim_buf_delete(bufnr, { force = true })
        elseif type(matches) == "table" then
            for _, match in ipairs(matches) do
                if type(match) == "string" and condition == match then
                    api.nvim_buf_delete(bufnr, { force = true })
                    return
                end
            end
        end
    end)
end

--- Close all buffers matching the specified filetypes or buffer types.
---
--- @param matches string|table The filetypes or buffer types to close.
--- @param condition_name string Can be "filetype" or "buftype".
function M.close_buffers_matching(matches, condition_name)
    for _, buf in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_valid(buf) then M.close_buffer_matching(buf, matches, condition_name) end
    end
end

--- Fast close all buffers matching the specified filetypes or buffer types.
---
--- @param matches string|table The filetypes or buffer types to close.
--- @param condition_name string Can be "filetype" or "buftype".
function M.close_buffers_matching_in_visible_windows(matches, condition_name)
    local wins = api.nvim_list_wins()
    for _, win in ipairs(wins) do
        M.close_buffer_matching(api.nvim_win_get_buf(win), matches, condition_name)
    end
end

--- Close buffers specified by buffer numbers or filetypes/buftypes.
---
--- @param matches number|table The buffer numbers or table with filetypes/buftypes.
function M.close_buffers(matches)
    if type(matches) == "number" and api.nvim_buf_is_valid(matches) then
        vim.schedule(function() api.nvim_buf_delete(matches, { force = true }) end)
    elseif type(matches) == "table" then
        for _, buf in ipairs(matches) do
            if type(buf) == "number" and api.nvim_buf_is_valid(buf) then
                vim.schedule(function() api.nvim_buf_delete(buf, { force = true }) end)
            end
        end
        for _, buf in ipairs(api.nvim_list_bufs()) do
            if api.nvim_buf_is_valid(buf) then
                M.close_buffer_matching(buf, matches, "filetype")
                M.close_buffer_matching(buf, matches, "buftype")
            end
        end
    end
end

return M
