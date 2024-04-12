local lsp = require("lsp-zero")

lsp.preset("recommended")

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = { 'tsserver', 'eslint', 'lua_ls', 'elixirls', 'terraformls', 'tflint' },
  handlers = {
    lsp.default_setup,
  },
})

lsp.set_preferences({
  suggest_lsp_servers = false,
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end

  if client.name == "eslint" then
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true
  end

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

  require "lsp_signature".on_attach({}, bufnr)

  -- format on save
  vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format(nil, 300)")
end)

-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
})

lsp.configure("elixirls", {
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
      fetchDeps = false,
    }
  },
  root_dir = function()
    return vim.loop.cwd()
  end
})

lsp.setup()

local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require('lspkind')

cmp.setup({
  sources = {
    { name = "copilot", group_index = 2 },
    { name = "nvim_lsp" },
    { name = 'luasnip', keyword_length = 2 },
    { name = "path" },
    { name = "buffer" },
  },
  mapping = {
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
        -- this will auto complete if our cursor in next to a word and we press tab
        -- elseif has_words_before() then
        --     cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" })
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol",
      max_width = 50,
      symbol_map = { Copilot = "" },
      show_item_kind = true,
    })
  }
})

vim.diagnostic.config({
  virtual_text = true,
})
