-- ============================================================
-- plugins/dap.lua
-- Debug Adapter Protocol (generic). Cấu hình adapter riêng từng
-- ngôn ngữ nằm ở lua/languages/<lang>/dap.lua, nạp qua registry.
-- ============================================================

local languages = require("languages")

local dependencies = {
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
    },
    "theHamsta/nvim-dap-virtual-text",
}
vim.list_extend(dependencies, languages.dap_dependencies())

return {
    "mfussenegger/nvim-dap",
    ft           = languages.dap_ft(),
    dependencies = dependencies,

    config = function()
        local dap       = require("dap")
        local dapui     = require("dapui")
        local dap_langs = languages.dap()
        local icons     = require("core.material").ascii

        -- ============================================================
        -- 1. Khởi tạo adapter cho từng ngôn ngữ đã bật
        -- ============================================================
        for _, cfg in ipairs(dap_langs) do
            if cfg.setup then cfg.setup() end
        end

        -- ============================================================
        -- 2. Cấu hình frames DAP UI
        -- ============================================================
        local frames = {
            scopes      = 0.7,
            stacks      = false,
            watches     = false,
            breakpoints = false,
            console     = false,
            repl        = 0.3,
        }

        local function build(ids)
            local out = {}
            for _, id in ipairs(ids) do
                local size = frames[id]
                if size then
                    table.insert(out, { id = id, size = size })
                end
            end
            return out
        end

        local right = build({ "scopes", "console", "watches", "stacks", "breakpoints", "repl" })
        local layouts = {}
        if #right > 0 then
            table.insert(layouts, { elements = right, size = 40, position = "right" })
        end

        -- ============================================================
        -- 3. Cấu hình giao diện DAP UI
        -- ============================================================
        dapui.setup({
            expand_lines = false,
            icons = {
                expanded = icons.expand,
                collapsed = icons.collapse,
                current_frame = icons.dap.current_frame,
            },
            controls = {
                enabled = false,
            },
            floating = {
                border = "rounded",
                mappings = { close = { "q", "<Esc>" } },
            },
            layouts = layouts,
        })

        -- ============================================================
        -- 4. Cấu hình Virtual Text hiển thị giá trị biến inline
        -- ============================================================
        require("nvim-dap-virtual-text").setup({
            enabled = true,
            commented = true,
            virt_text_pos = "eol",
            all_frames = false,
            highlight_changed_variables = true,
        })

        -- ============================================================
        -- 5. Tự động bật/tắt DAP UI theo phiên debug
        -- ============================================================
        dap.listeners.before.attach.dapui_config = function() dapui.open() end
        dap.listeners.before.launch.dapui_config = function() dapui.open() end
        -- dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
        -- dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

        -- ============================================================
        -- 6. Ký hiệu Breakpoint (ASCII)
        -- ============================================================
        vim.fn.sign_define("DapBreakpoint",          { text = icons.dap.breakpoint,           texthl = "DapBreakpoint", numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition", { text = icons.dap.breakpoint_condition, texthl = "DapBreakpointCondition", numhl = "" })
        vim.fn.sign_define("DapLogPoint",            { text = icons.dap.log_point,            texthl = "DapLogPoint", numhl = "" })
        vim.fn.sign_define("DapStopped",             { text = icons.dap.stopped,              texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStopped" })
        vim.fn.sign_define("DapBreakpointRejected",  { text = icons.dap.breakpoint_rejected,  texthl = "DapBreakpointRejected", numhl = "" })

        -- ============================================================
        -- 7. Phím tắt điều khiển (generic)
        -- ============================================================
        local map = vim.keymap.set
        local function k(lhs, rhs, desc)
            map("n", lhs, rhs, { silent = true, noremap = true, desc = desc })
        end

        -- Điều khiển luồng (F5-F12)
        k("<F5>",  dap.continue,  "Debug: Continue / Start")
        k("<F10>", dap.step_over, "Debug: Step Over")
        k("<F11>", dap.step_into, "Debug: Step Into")
        k("<F12>", dap.step_out,  "Debug: Step Out")

        -- Quản lý Breakpoint
        k("<leader>db", dap.toggle_breakpoint, "Toggle Breakpoint")
        k("<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, "Conditional Breakpoint")
        k("<leader>dL", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log message: ")) end, "Log Point")

        -- Quản lý Phiên (Session)
        k("<leader>dc", dap.continue,  "Continue / Start")
        k("<leader>dr", dap.repl.open, "Open REPL")
        k("<leader>dl", dap.run_last,  "Run Last Session")
        k("<leader>dq", dap.terminate, "Terminate Session")
        k("<leader>du", dapui.toggle,  "Toggle DAP UI")

        -- Đánh giá (Eval) biến dưới con trỏ
        k("<leader>de", function() dapui.eval(nil, { enter = true }) end, "Eval Expression")
        map("v", "<leader>de", function() dapui.eval(nil, { enter = true }) end, { silent = true, desc = "Eval Selection" })

        -- ============================================================
        -- 8. Phím tắt riêng theo ngôn ngữ
        -- ============================================================
        for _, cfg in ipairs(dap_langs) do
            if cfg.keys then cfg.keys(k) end
        end
    end,
}
