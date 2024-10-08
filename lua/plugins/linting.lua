-- Plugin: Lint
-- See: https://github.com/mfussenegger/nvim-lint
return {
    'mfussenegger/nvim-lint',
    event = {
        'BufReadPre',
        'BufNewFile'
    },
    opts = {
        -- other config
        linters = {
            eslint_d = {
                args = {
                    '--no-warn-ignored',
                    '--format',
                    'json',
                    '--stdin',
                    '--stdin-filename',
                    function()
                        return vim.api.nvim_buf_get_name(0)
                    end,
                },
            },
        },
    },
    config = function()
        -- config
        local lint = require('lint')

        lint.linters_by_ft = {
            javascript = { 'eslint_d' },
            typescript = { 'eslint_d' },
            svelte = { 'eslint_d' },
        }

        local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        lint.linters.eslint_d = require("lint.util").wrap(lint.linters.eslint_d, function(diagnostic)
            -- try to ignore "No ESLint configuration found" error
            -- if diagnostic.message:find("Error: No ESLint configuration found") then -- old version
            -- update: 20240814, following is working
            if diagnostic.message:find("Error: Could not find config file") then
                return nil
            end
            return diagnostic
        end)

        -- keymaps
        vim.keymap.set('n', '<leader>l', function()
            lint.try_lint()
        end, { desc = 'Trigger linting for current file' })
    end,
}
