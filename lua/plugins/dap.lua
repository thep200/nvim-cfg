-- ============================================================
--  plugins/dap.lua
--  Debug Adapter Protocol cho Go (qua delve).
--
--  Stack:
--    - nvim-dap                : DAP client core (port từ VSCode DAP spec)
--    - nvim-dap-ui             : UI panel (scopes, stacks, breakpoints, repl)
--    - nvim-dap-virtual-text   : show value biến INLINE cuối dòng khi paused
--    - nvim-dap-go             : preset config cho Go (auto-detect delve,
--                                lệnh debug_test() chạy test tại con trỏ)
--
--  ⚠️ delve KHÔNG quản lý qua Mason - bạn tự cài qua mise.
--    nvim-dap-go sẽ tìm `dlv` trong $PATH (mise shim đảm bảo có).
--
--  Workflow cơ bản:
--    1. Đặt cursor ở dòng cần dừng -> <leader>db để toggle breakpoint
--    2. <F5> hoặc <leader>dc để Start/Continue
--    3. DAP UI tự bật, hiển thị scope/stack/watch
--    4. <F10>/<F11>/<F12> để step over/into/out
--    5. <leader>dq để kết thúc session (UI tự đóng)
-- ============================================================

return {
    "mfussenegger/nvim-dap",
    ft = { "go" }, -- chỉ load khi mở file .go
    -- -> không ảnh hưởng startup khi edit file khác
    dependencies = {
        -- UI panel (scopes/stacks/breakpoints/repl)
        {
            "rcarriga/nvim-dap-ui",
            -- nvim-dap-ui từ phiên bản mới yêu cầu nvim-nio (async runtime).
            -- Không khai báo -> báo lỗi "module 'nio' not found" khi setup.
            dependencies = { "nvim-neotest/nvim-nio" },
        },

        -- Inline virtual text show giá trị biến cuối dòng khi paused
        "theHamsta/nvim-dap-virtual-text",

        -- Go-specific config (wrap delve, hỗ trợ debug test/package)
        "leoluz/nvim-dap-go",
    },

    config = function()
        local dap   = require("dap")
        local dapui = require("dapui")

        -- ============================================================
        -- 1. nvim-dap-go: cấu hình adapter Go + lệnh debug test
        --
        -- nvim-dap-go tìm `dlv` trong $PATH. Mise shim đảm bảo điều này
        -- khi Neovim được launch từ shell có mise hooked (zsh/bash với
        -- `mise activate`). Nếu Neovim được launch từ GUI (ít gặp với
        -- terminal user), có thể phải set tay đường dẫn dlv:
        --
        --   delve = { path = vim.fn.expand("~/.local/share/mise/...") }
        -- ============================================================
        require("dap-go").setup({
            delve = {
                -- timeout chờ delve khởi động (giây)
                timeout  = 20,
                -- detach khi disconnect -> delve không treo background
                detached = true,
            },
        })

        -- ============================================================
        -- 2. nvim-dap-ui: layout panel
        --
        -- Mặc định: side panel bên trái (scopes/breakpoints/stacks/watches)
        -- + bottom panel (repl + console).
        -- ============================================================
        dapui.setup({
            -- Icons CHỮ (không Nerd Font) - giữ style ASCII của bạn
            icons = {
                expanded      = "v", -- folder mở trong scope tree
                collapsed     = ">", -- folder đóng
                current_frame = "*",
            },
            controls = {
                -- Tắt control buttons (icon đẹp cần Nerd Font, ta dùng keymap)
                enabled = false,
            },
            -- Floating window khi gọi dapui.eval(), hover...
            floating = {
                border   = "rounded",
                mappings = { close = { "q", "<Esc>" } },
            },
        })

        -- ============================================================
        -- 3. nvim-dap-virtual-text: hiển thị value INLINE khi paused
        -- ============================================================
        require("nvim-dap-virtual-text").setup({
            enabled                     = true,
            commented                   = true, -- show value sau ký tự comment "// "
            -- của Go -> trông tự nhiên
            virt_text_pos               = "eol",
            all_frames                  = false,
            highlight_changed_variables = true,
        })

        -- ============================================================
        -- 4. Listeners: auto open/close DAP UI theo lifecycle debug session
        -- ============================================================
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        -- ============================================================
        -- 5. Sign column - giữ style ASCII đồng bộ gitsigns
        --
        --   ●  breakpoint thường
        --   ◆  breakpoint điều kiện / logpoint
        --   ▶  dòng đang dừng (current frame)
        --   ✗  breakpoint bị reject (sai cú pháp, hoặc dlv không bind được)
        -- ============================================================
        vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", numhl = "" })
        vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", numhl = "" })
        vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStopped" })
        vim.fn.sign_define("DapBreakpointRejected", { text = "✗", texthl = "DapBreakpointRejected", numhl = "" })

        -- ============================================================
        -- 6. Keymaps
        --
        -- Namespace <leader>d* = "Debug ..." (chưa dùng trước đây)
        -- F5/F10/F11/F12 = quy ước universal VSCode/JetBrains
        -- ============================================================
        local map = vim.keymap.set
        local function k(lhs, rhs, desc)
            map("n", lhs, rhs, { silent = true, noremap = true, desc = desc })
        end

        -- ---- Control flow (giống quy ước VSCode/JetBrains) ----
        k("<F5>", dap.continue, "Debug: Continue / Start")
        k("<F10>", dap.step_over, "Debug: Step Over")
        k("<F11>", dap.step_into, "Debug: Step Into")
        k("<F12>", dap.step_out, "Debug: Step Out")

        -- ---- Breakpoint ----
        k("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
        k("<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "Conditional breakpoint")
        k("<leader>dL", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log message: ")) end, "Log point")

        -- ---- Session ----
        k("<leader>dc", dap.continue, "Continue / Start")
        k("<leader>dr", dap.repl.open, "Open REPL")
        k("<leader>dl", dap.run_last, "Run last debug session")
        k("<leader>dq", dap.terminate, "Terminate session")
        k("<leader>du", dapui.toggle, "Toggle DAP UI")

        -- ---- Eval biến/expression dưới con trỏ ----
        k("<leader>de", function() dapui.eval(nil, { enter = true }) end, "Eval expression under cursor")
        map("v", "<leader>de", function() dapui.eval(nil, { enter = true }) end, { silent = true, desc = "Eval visual selection" })

        -- ---- Go-specific (từ nvim-dap-go) ----
        k("<leader>dt", function() require("dap-go").debug_test() end, "Debug nearest Go test")
        k("<leader>dT", function() require("dap-go").debug_last_test() end, "Debug last Go test")
    end,
}
