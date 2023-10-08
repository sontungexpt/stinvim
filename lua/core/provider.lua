local g = vim.g

g.ruby_host_prog = "~/.rbenv/versions/3.2.2/bin/neovim-ruby-host"
g.python3_host_prog = "~/.venv/bin/python3"

-- disable some providers
local disabled = {
	"perl",
	"ruby",
}

for _, provider in ipairs(disabled) do
	g["loaded_" .. provider .. "_provider"] = 0
end
