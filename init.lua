local require = require

-- core module
require("core.environment")
require("core.option")
require("core.autocmd")
require("core.keymaps").setup()
require("core.bootstrap").boot()
