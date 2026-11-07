-- ------------------------------------------------------- AI --------------------------------------------------------
-- AI-powered coding assistance plugins.
-- Mission: Provide AI autocomplete suggestions, chat, and code generation features.
return {
	-- AI-powered inline code completion (Windsurf/Codeium)
	{
		"monkoose/neocodeium",
		event = "InsertEnter",
		opts = {},
	},
}
