require('lualine').setup({
  options = {
    theme = 'gruvbox'
  },
  sections = {
    lualine_c = {
      {
        'filename',
        filestatus = true,
        path = 2,
      }
    }
  }
})
