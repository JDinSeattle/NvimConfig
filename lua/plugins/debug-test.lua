local function setup_codelldb(dap)
	local codelldb = vim.fn.exepath("codelldb")
	if codelldb == "" then
		return
	end

	dap.adapters.codelldb = {
		type = "server",
		port = "${port}",
		executable = {
			command = codelldb,
			args = { "--port", "${port}" },
		},
	}

	local launch = {
		name = "Launch executable",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	}

	dap.configurations.c = { launch }
	dap.configurations.cpp = { launch }
end

local function setup_debugpy()
	local ok, dap_python = pcall(require, "dap-python")
	if not ok then
		return
	end

	local python = vim.fn.exepath("python3")
	local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
	if vim.fn.executable(debugpy) == 1 then
		python = debugpy
	end
	dap_python.setup(python)
end

local function setup_neotest()
	local adapters = {}

	local ok_go, go = pcall(require, "neotest-golang")
	if ok_go then
		table.insert(adapters, go({ dap_go_enabled = true }))
	end

	local ok_python, python = pcall(require, "neotest-python")
	if ok_python then
		table.insert(adapters, python({ dap = { justMyCode = false } }))
	end

	local ok_rust, rust = pcall(require, "rustaceanvim.neotest")
	if ok_rust then
		table.insert(adapters, rust)
	end

	require("neotest").setup({ adapters = adapters })
end

local function lsp_capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local ok, blink = pcall(require, "blink.cmp")
	if ok and blink.get_lsp_capabilities then
		return blink.get_lsp_capabilities(capabilities)
	end
	return capabilities
end

return {
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		opts = {
			ensure_installed = { "codelldb", "debugpy", "delve" },
			automatic_installation = true,
			handlers = {},
		},
	},

	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"leoluz/nvim-dap-go",
			"mfussenegger/nvim-dap-python",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local dap = require("dap")
			setup_codelldb(dap)

			local ok_go, dap_go = pcall(require, "dap-go")
			if ok_go then
				dap_go.setup()
			end

			setup_debugpy()
			require("nvim-dap-virtual-text").setup()
		end,
	},

	{
		"igorlfs/nvim-dap-view",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
	},

	{
		"mrcjkb/rustaceanvim",
		ft = { "rust" },
		init = function()
			local codelldb = vim.fn.exepath("codelldb")
			local lib_ext = vim.uv.os_uname().sysname == "Linux" and ".so" or ".dylib"
			local library_path = vim.fn.expand("$MASON/opt/lldb/lib/liblldb" .. lib_ext)

			vim.g.rustaceanvim = {
				server = {
					capabilities = lsp_capabilities(),
					on_attach = function(_, bufnr)
						vim.keymap.set("n", "<leader>cR", function()
							vim.cmd.RustLsp("codeAction")
						end, { buffer = bufnr, desc = "[Rust] Code action" })
						vim.keymap.set("n", "<leader>dr", function()
							vim.cmd.RustLsp("debuggables")
						end, { buffer = bufnr, desc = "[Rust] Debuggables" })
					end,
					default_settings = {
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
								loadOutDirsFromCheck = true,
								buildScripts = { enable = true },
							},
							check = { command = "clippy" },
							checkOnSave = true,
							completion = {
								autoimport = { enable = true },
							},
							diagnostics = { enable = true },
							imports = {
								granularity = { group = "module" },
								prefix = "self",
							},
							procMacro = { enable = true },
						},
					},
				},
			}

			if codelldb ~= "" and vim.fn.filereadable(library_path) == 1 then
				vim.g.rustaceanvim.dap = {
					adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
				}
			end
		end,
	},

	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"fredrikaverpil/neotest-golang",
			"nvim-neotest/neotest-python",
			"mrcjkb/rustaceanvim",
		},
		keys = {
			{
				"<leader>rn",
				function()
					require("neotest").run.run()
				end,
				desc = "[Test] Run nearest",
			},
			{
				"<leader>rT",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "[Test] Run file",
			},
			{
				"<leader>ro",
				function()
					require("neotest").output.open({ enter = true })
				end,
				desc = "[Test] Output",
			},
			{
				"<leader>rS",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "[Test] Summary",
			},
		},
		config = setup_neotest,
	},
}
