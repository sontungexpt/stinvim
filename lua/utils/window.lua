local function at_top_edge() return vim.fn.winnr() == vim.fn.winnr("k") end
local function at_bottom_edge() return vim.fn.winnr() == vim.fn.winnr("j") end
local function at_left_edge() return vim.fn.winnr() == vim.fn.winnr("h") end
local function at_right_edge() return vim.fn.winnr() == vim.fn.winnr("l") end
