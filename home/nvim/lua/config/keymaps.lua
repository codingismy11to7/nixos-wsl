-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

if vim.env.ZELLIJ_SESSION_NAME and vim.env.ZELLIJ_SESSION_NAME ~= "" then
  map({ "n" }, "<c-h>", "<cmd>ZellijNavigateLeft!<cr>", { desc = "Navigate Left" })
  map({ "n" }, "<c-l>", "<cmd>ZellijNavigateRight!<cr>", { desc = "Navigate Right" })
  map({ "n" }, "<c-j>", "<cmd>ZellijNavigateDown<cr>", { desc = "Navigate Down" })
  map({ "n" }, "<c-k>", "<cmd>ZellijNavigateUp<cr>", { desc = "Navigate Up" })

  local function run_zellij_cmd(zellij_cmd)
    local user_input = vim.fn.input("Command: ")
    if user_input and user_input ~= "" then
      vim.cmd(zellij_cmd .. " " .. user_input)
    end
  end

  local zellij_maps = {
    { key = "f", cmd = "ZellijNewPane", desc = "New Floating Pane" },
    { key = "p", cmd = "ZellijNewPaneSplit", desc = "New Pane Below" },
    { key = "P", cmd = "ZellijNewPaneVSplit", desc = "New Pane Beside" },
    { key = "t", cmd = "ZellijNewTab", desc = "New Tab" },
  }

  for _, config in ipairs(zellij_maps) do
    map({ "n" }, "<leader>z" .. config.key, "<cmd>" .. config.cmd .. "<cr>", { desc = "Zellij " .. config.desc })

    map({ "n" }, "<leader>zr" .. config.key, function()
      run_zellij_cmd(config.cmd)
    end, { desc = "Zellij Run in " .. config.desc })
  end
end
