return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- Set header
    -- 		dashboard.section.header.val = {
    -- 	"███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗     ██████╗ ",
    -- 	"████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║     ╚════██╗",
    -- 	"██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║█████╗█████╔╝",
    -- 	"██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║╚════╝╚═══██╗",
    -- 	"██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║     ██████╔╝",
    -- 	"╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝     ╚═════╝ ",
    -- 	"                                                               ",
    -- 	"                      You Can (Not) Code                       ",
    -- }
    dashboard.section.header.val = {
      '      ███╗   ██╗███████╗██╗    ██╗    ██╗   ██╗██╗███╗   ███╗     ██████╗   ',
      '      ████╗  ██║██╔════╝██║    ██║    ██║   ██║██║████╗ ████║     ╚════██╗  ',
      '      ██╔██╗ ██║█████╗  ██║ █╗ ██║    ██║   ██║██║██╔████╔██║█████╗█████╔╝  ',
      '      ██║╚██╗██║██╔══╝  ██║███╗██║    ╚██╗ ██╔╝██║██║╚██╔╝██║╚════╝╚═══██╗  ',
      '      ██║ ╚████║███████╗╚███╔███╔╝     ╚████╔╝ ██║██║ ╚═╝ ██║     ██████╔╝  ',
      '      ╚═╝  ╚═══╝╚══════╝ ╚══╝╚══╝       ╚═══╝  ╚═╝╚═╝     ╚═╝     ╚═════╝   ',
      '                                                                            ',
      '                             YOU CAN (NOT) CODE.                            ', --poster version
      -- "                         You Can (Not) Code                           ",
    }

    -- Set menu
    dashboard.section.buttons.val = {
      --you can also specify keymaps that only work in this greeter eg you can set just e to make a new file
      dashboard.button('e', '  > New File', '<cmd>ene<CR>'),
      dashboard.button('SPC ee', '  > Toggle file explorer', '<cmd>NvimTreeToggle<CR>'),
      dashboard.button('SPC ff', '󰱼  > Find File', '<cmd>Telescope find_files<CR>'),
      dashboard.button('SPC fg', '  > Find Word with grep', '<cmd>Telescope live_grep<CR>'),
      dashboard.button('SPC fr', '  > Find Recent files', '<cmd>Telescope oldfiles<CR>'),
      dashboard.button('tc', '󰃣  > Theme Change', '<cmd>Telescope colorscheme<CR>'),
      -- dashboard.button(
      -- 	"SPC wr",
      -- 	"󰁯  > Restore Session For Current Directory",
      -- 	"<cmd>SessionRestore<CR>"
      -- ),
      dashboard.button('q', '  > Quit NVIM', '<cmd>qa<CR>'),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
  end,
}
--other silly ASCII greeters
--
-- "  ███╗   ██╗██╗   ██╗██╗███╗   ███╗       ██████╗     ██╗ ██████╗ ",
-- "  ████╗  ██║██║   ██║██║████╗ ████║      ██╔═████╗   ███║██╔═████ ",
-- "  ██╔██╗ ██║██║   ██║██║██╔████╔██║█████╗██║██╔██║   ╚██║██║██╔██ ",
-- "  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║╚════╝████╔╝██║    ██║████╔╝██ ",
-- "  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║      ╚██████╔╝██╗ ██║╚██████╔ ",
-- "  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝       ╚═════╝ ╚═╝ ╚═╝ ╚═════╝ ",
-- "			   YOU CAN (NOT) CODE			   ",
--
--
-- " ██████╗ ██╗██████╗  ██████╗ ",
-- "██╔════╝███║██╔══██╗██╔═████╗",
-- "██║     ╚██║██████╔╝██║██╔██║",
-- "██║      ██║██╔═══╝ ████╔╝██║",
-- "╚██████╗ ██║██║     ╚██████╔╝",
-- " ╚═════╝ ╚═╝╚═╝      ╚═════╝ ",
--
-- " ______     __     ______   ______   ",
-- "/\  ___\   /\ \   /\  == \ /\  __ \  ",
-- "\ \ \____  \ \ \  \ \  _-/ \ \ \/\ \ ",
-- " \ \_____\  \ \_\  \ \_\    \ \_____\",
-- "  \/_____/   \/_/   \/_/     \/_____/",
--
-- '   ██████╗ ██╗   ██████╗  ██████╗ ",
-- '  ██╔════╝███║   ██╔══██╗██╔═████╗",
-- '  ██║     ╚██║   ██████╔╝██║██╔██║",
-- '  ██║      ██║   ██╔═══╝ ████╔╝██║",
-- '  ╚██████╗ ██║██╗██║██╗  ╚██████╔╝",
-- '   ╚═════╝ ╚═╝╚═╝╚═╝╚═╝   ╚═════╝ ",
-- '                                  ",
