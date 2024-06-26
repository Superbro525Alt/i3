local status_ok, lualine = pcall(require, 'lualine')
if not status_ok then
    return
end

-- Color table for highlights
-- stylua: ignore
local colors = {
    bg       = '#202328',
    fg       = '#bbc2cf',
    yellow   = '#ECBE7B',
    cyan     = '#008080',
    darkblue = '#081633',
    green    = '#98be65',
    orange   = '#FF8800',
    violet   = '#a9a1e1',
    magenta  = '#c678dd',
    blue     = '#51afef',
    red      = '#ec5f67',
}

local icons = require('user.icons')

local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
        local filepath = vim.fn.expand('%:p:h')
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
}

-- Config
local config = {
    options = {
        -- Disable sections and component separators
        component_separators = '',
        section_separators = '',
        theme = 'onedark',
        -- theme = {
        --     -- We are going to use lualine_c an lualine_x as left and
        --     -- right section. Both are highlighted by c theme .  So we
        --     -- are just setting default looks o statusline
        --     normal = { c = { fg = colors.fg, bg = colors.bg } },
        --     inactive = { c = { fg = colors.fg, bg = colors.bg } },
        -- },
    },
    sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_x = {},
    },
    inactive_sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
    },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
end

ins_left({
    function()
        return '▊'
    end,
    color = { fg = colors.blue }, -- Sets highlighting of component
    padding = { left = 0, right = 1 }, -- We don't need space before this
})

ins_left({
    "mode",
	fmt = function(str)
		return "-- " .. str .. " --"
	end,
    -- mode component
})

ins_left({ 'location' })

ins_left({
    'filename',
    fmt = function(str)
        return str:sub(1, 16)
    end,
    cond = conditions.buffer_not_empty,
    color = { fg = colors.magenta, gui = 'bold' },
})

ins_left({
    'diff',
    symbols = { added = icons.git.Add, modified = icons.git.Mod, removed = icons.git.Remove },
    diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red },
    },
    cond = conditions.hide_in_width,
})

ins_left({
    'diagnostics',
    sources = { 'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic' },
    symbols = {
        error = icons.diagnostics.Error,
        warn = icons.diagnostics.Warning,
        info = icons.diagnostics.Information,
        hint = icons.diagnostics.Hint,
    },
    diagnostics_color = {
        color_error = { fg = colors.red },
        color_warn = { fg = colors.yellow },
        color_info = { fg = colors.blue },
        color_hint = { fg = colors.yellow },
    },
})

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left({
    function()
        return '%='
    end,
})

ins_left({
    -- Lsp server name .
    function()
        local msg = 'No LSP'
        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
            return msg
        end
        for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
            end
        end
        return msg
    end,
    icon = icons.ui.Gear .. ' :',
    color = { fg = colors.fg, gui = 'bold' },
})

-- Add components to right sections
ins_right({
    'branch',
    icon = icons.git.Branch,
    fmt = function(str)
        return str:sub(1, 16)
    end,
    color = { fg = colors.violet, gui = 'bold' },
})

ins_right({ 'progress', color = { fg = colors.fg, gui = 'bold' } })

ins_right({
    -- filesize component
    'filesize',
    color = { fg = colors.fg, gui = 'bold' },
    cond = conditions.buffer_not_empty,
})

ins_right({
    'filetype',
    color = { fg = colors.blue, gui = 'bold' },
})

ins_right({
    'fileformat',
    icons_enabled = true,
    color = { fg = colors.white, gui = 'bold' },
})

local spaces = function()
	return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
end

ins_right({
spaces

})

ins_right({
    'o:encoding', -- option component same as &encoding in viml
    fmt = string.upper,
    cond = conditions.hide_in_width,
    color = { fg = colors.green, gui = 'bold' },
})

ins_right({
    function()
        return '▊'
    end,
    color = { fg = colors.blue },
    padding = { left = 1 },
})

-- Now don't forget to initialize lualine
lualine.setup(config)
