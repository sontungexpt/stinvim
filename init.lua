local require = require

-- core module
require("core.option")
require("core.environment")
require("core.autocmd")
require("core.keymaps").setup()
require("core.bootstrap").boot()
