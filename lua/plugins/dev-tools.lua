local tools = {
  "actionlint",
  "ansible-language-server",
  "ansible-lint",
  "bacon",
  "bacon-ls",
  "bash-language-server",
  "basedpyright",
  "black",
  "buf",
  "clang-format",
  "clangd",
  "cmakelang",
  "cmakelint",
  "codespell",
  "codelldb",
  "debugpy",
  "delve",
  "docker-compose-language-service",
  "dockerfile-language-server",
  "eslint-lsp",
  "flake8",
  "gofumpt",
  "goimports",
  "goimports-reviser",
  "golangci-lint",
  "golines",
  "gomodifytags",
  "gopls",
  "gotests",
  "gotestsum",
  "hadolint",
  "helm-ls",
  "iferr",
  "impl",
  "isort",
  "json-lsp",
  "lua-language-server",
  "markdown-toc",
  "markdownlint-cli2",
  "marksman",
  "mypy",
  "neocmakelsp",
  "prettier",
  "pylint",
  "pyright",
  "ruff",
  "rust-analyzer",
  "shellcheck",
  "shfmt",
  "sqlfluff",
  "staticcheck",
  "stylua",
  "taplo",
  "terraform",
  "terraform-ls",
  "tflint",
  "tree-sitter-cli",
  "typescript-language-server",
  "vtsls",
  "yaml-language-server",
  "yamllint",
  "yamlfmt",
}

local function append_unique(list, values)
  for _, value in ipairs(values) do
    if not vim.tbl_contains(list, value) then
      table.insert(list, value)
    end
  end
end

return {
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "[Mason] Open registry" },
    },
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      append_unique(opts.ensure_installed, tools)
    end,
    config = function(_, opts)
      require("mason").setup(opts)
      if #vim.api.nvim_list_uis() == 0 then
        return
      end

      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs(opts.ensure_installed or {}) do
          local ok, package = pcall(registry.get_package, name)
          if ok and not package:is_installed() and not package:is_installing() then
            package:install()
          end
        end
      end)
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      append_unique(opts.ensure_installed, { "codelldb", "debugpy", "delve" })
    end,
  },
}
