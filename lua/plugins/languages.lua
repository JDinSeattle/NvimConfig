local function merge_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.get_lsp_capabilities then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end
  return capabilities
end

local function lsp_on_attach(_, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "[LSP] Go to definition")
  map("n", "gD", vim.lsp.buf.declaration, "[LSP] Go to declaration")
  map("n", "gr", vim.lsp.buf.references, "[LSP] References")
  map("n", "gi", vim.lsp.buf.implementation, "[LSP] Implementation")
  map("n", "gy", vim.lsp.buf.type_definition, "[LSP] Type definition")
  map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "[LSP] Code action")
  map("n", "<leader>cr", vim.lsp.buf.rename, "[LSP] Rename")
  map("n", "<leader>cf", function()
    require("conform").format({ bufnr = bufnr, async = true, lsp_format = "fallback" })
  end, "[Format] Buffer")
  map("n", "K", vim.lsp.buf.hover, "[LSP] Hover")
end

local function setup_lsp_servers()
  local capabilities = merge_capabilities()

  local json_schemas = {}
  local yaml_schemas = {}
  local ok_schema, schemastore = pcall(require, "schemastore")
  if ok_schema then
    json_schemas = schemastore.json.schemas()
    yaml_schemas = schemastore.yaml.schemas()
  end

  local servers = {
    ansiblels = {},
    bashls = {},
    basedpyright = {
      settings = {
        basedpyright = {
          analysis = {
            autoSearchPaths = true,
            autoImportCompletions = true,
            diagnosticMode = "openFilesOnly",
            typeCheckingMode = "standard",
            useLibraryCodeForTypes = true,
          },
        },
      },
    },
    clangd = {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--header-insertion-decorators",
      },
      init_options = {
        fallbackFlags = { "-std=c11" },
      },
    },
    docker_compose_language_service = {},
    dockerls = {},
    eslint = {},
    gopls = {
      init_options = {
        semanticTokens = true,
      },
      settings = {
        gopls = {
          gofumpt = true,
          codelenses = {
            gc_details = false,
            generate = true,
            regenerate_cgo = true,
            run_govulncheck = true,
            test = true,
            tidy = true,
            upgrade_dependency = true,
            vendor = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          analyses = {
            nilness = true,
            unusedparams = true,
            unusedwrite = true,
            useany = true,
          },
          completeUnimported = true,
          staticcheck = true,
          usePlaceholders = true,
        },
      },
    },
    helm_ls = {},
    jsonls = {
      settings = {
        json = {
          schemas = json_schemas,
          validate = { enable = true },
        },
      },
    },
    lua_ls = {
      settings = {
        Lua = {
          completion = { callSnippet = "Replace" },
          diagnostics = { globals = { "vim" } },
          runtime = { version = "LuaJIT" },
          telemetry = { enable = false },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file("", true),
          },
        },
      },
    },
    marksman = {},
    neocmake = {},
    ruff = {},
    taplo = {},
    terraformls = {},
    vtsls = {
      settings = {
        javascript = {
          preferences = {
            includePackageJsonAutoImports = "auto",
          },
          suggest = {
            autoImports = true,
            completeFunctionCalls = true,
          },
        },
        typescript = {
          preferences = {
            includePackageJsonAutoImports = "auto",
          },
          suggest = {
            autoImports = true,
            completeFunctionCalls = true,
          },
        },
        vtsls = {
          autoUseWorkspaceTsdk = true,
        },
      },
    },
    yamlls = {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = "" },
          schemas = yaml_schemas,
        },
      },
    },
  }

  for server, config in pairs(servers) do
    config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
    config.on_attach = config.on_attach or lsp_on_attach
    local ok, err = pcall(function()
      vim.lsp.config(server, config)
      vim.lsp.enable(server)
    end)
    if not ok then
      vim.notify("Skipped LSP server: " .. server .. ": " .. tostring(err), vim.log.levels.WARN)
    end
  end
end

local function autoformat_enabled(bufnr)
  if vim.b[bufnr].autoformat ~= nil then
    return vim.b[bufnr].autoformat
  end
  if vim.g.autoformat == nil then
    return true
  end
  return vim.g.autoformat
end

local treesitter_parsers = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "css",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "gotmpl",
  "gowork",
  "hcl",
  "helm",
  "html",
  "javascript",
  "json",
  "json5",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "ron",
  "rust",
  "sql",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  {
    "saghen/blink.cmp",
    version = false,
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "enter",
        ["<CR>"] = { "select_and_accept", "fallback" },
      },
      completion = {
        accept = { resolve_timeout_ms = 1000 },
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        ghost_text = { enabled = true },
        list = {
          selection = { preselect = true, auto_insert = false },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
    opts_extend = { "sources.default" },
  },

  { "rafamadriz/friendly-snippets", lazy = true },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  {
    "b0o/SchemaStore.nvim",
    lazy = true,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "ansiblels",
        "bashls",
        "basedpyright",
        "clangd",
        "docker_compose_language_service",
        "dockerls",
        "eslint",
        "gopls",
        "helm_ls",
        "jsonls",
        "lua_ls",
        "marksman",
        "neocmake",
        "ruff",
        "rust_analyzer",
        "taplo",
        "terraformls",
        "vtsls",
        "yamlls",
      },
      automatic_enable = false,
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
      "mason-org/mason-lspconfig.nvim",
    },
    config = setup_lsp_servers,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        sqlfluff = {
          args = { "format", "--dialect=ansi", "-" },
        },
      },
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        cmake = { "cmake_format" },
        go = { "goimports", "gofumpt" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
        python = { "ruff_fix", "ruff_format", "black" },
        sh = { "shfmt" },
        sql = { "sqlfluff" },
        terraform = { "terraform_fmt" },
        toml = { "taplo" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        yaml = { "prettier" },
      },
      format_on_save = function(bufnr)
        if not autoformat_enabled(bufnr) then
          return nil
        end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        cmake = { "cmakelint" },
        dockerfile = { "hadolint" },
        go = { "golangcilint" },
        markdown = { "markdownlint-cli2", "codespell" },
        python = { "ruff", "mypy" },
        sh = { "shellcheck" },
        sql = { "sqlfluff" },
        terraform = { "tflint" },
        text = { "codespell" },
        yaml = { "yamllint" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft or {}

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      if #vim.api.nvim_list_uis() > 0 then
        pcall(function()
          require("nvim-treesitter").install(treesitter_parsers)
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function()
          pcall(vim.treesitter.start)
          pcall(function()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end,
      })
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {},
      },
      checkbox = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      local ok, Snacks = pcall(require, "snacks")
      if ok and Snacks.toggle then
        Snacks.toggle({
          name = "Render Markdown",
          get = require("render-markdown").get,
          set = require("render-markdown").set,
        }):map("<leader>um")
      end
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown Preview" },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },

  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = { crates = { enabled = true } },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },

  {
    "Civitasv/cmake-tools.nvim",
    ft = "cmake",
    opts = {},
  },

  {
    "qvalentin/helm-ls.nvim",
    ft = "helm",
  },

  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },

  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = "vim-dadbod",
    ft = { "sql", "mysql", "plsql" },
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = "vim-dadbod",
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "[DB] Toggle UI" },
    },
    init = function()
      local data_path = vim.fn.stdpath("data")
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_execute_on_save = false
    end,
  },
}
