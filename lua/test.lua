vim.api.nvim_create_user_command("CMD", function(opts)
    vim.cmd("terminal")
end, {})
