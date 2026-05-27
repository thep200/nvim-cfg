-- ============================================================
-- plugins/cmp.lua
-- Cấu hình Autocomplete Engine (nvim-cmp)
-- Tích hợp: LSP, Snippets, Buffer, Path & GitHub Copilot
-- ============================================================

return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        -- Hàm kiểm tra xem Copilot có đang hiển thị gợi ý (Ghost Text) hay không
        local function has_copilot_suggestion()
            local ok, suggestion = pcall(vim.fn["copilot#GetDisplayedSuggestion"])
            return ok and suggestion ~= nil and suggestion.text ~= nil and suggestion.text ~= ""
        end

        cmp.setup({
            -- ============================================================
            -- 1. Snippet Engine (Bắt buộc phải có để mở rộng code)
            -- ============================================================
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },

            -- ============================================================
            -- 2. Nguồn dữ liệu Autocomplete (Xếp hạng theo độ ưu tiên)
            -- ============================================================
            sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip",  priority = 750  },
                { name = "buffer",   priority = 500, keyword_length = 3 },
                { name = "path",     priority = 250  },
            }),

            -- ============================================================
            -- 3. Cấu hình giao diện Popup (Giữ phong cách tối giản)
            -- ============================================================
            formatting = {
                fields = { "abbr", "kind", "menu" },
                format = function(entry, vim_item)
                    local menu_map = {
                        nvim_lsp = "[LSP]",
                        luasnip  = "[Snip]",
                        buffer   = "[Buf]",
                        path     = "[Path]",
                    }
                    vim_item.menu = menu_map[entry.source.name] or ""
                    return vim_item
                end,
            },

            window = {
                completion    = cmp.config.window.bordered({ border = "rounded" }),
                documentation = cmp.config.window.bordered({ border = "rounded" }),
            },

            -- ============================================================
            -- 4. Điều kiện kích hoạt & Thuật toán sắp xếp (Fuzzy Matching)
            -- ============================================================
            completion = {
                autocomplete   = { cmp.TriggerEvent.TextChanged },
                keyword_length = 1,
            },
            sorting = {
                priority_weight = 2,
                comparators = {
                    cmp.config.compare.offset,
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.locality,
                    cmp.config.compare.kind,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                },
            },

            -- ============================================================
            -- 5. Cấu hình Phím tắt (Bao gồm logic ưu tiên cho Copilot)
            -- ============================================================
            mapping = cmp.mapping.preset.insert({
                -- Fomat hiển thị popup
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"]     = cmp.mapping.abort(),
                ["<C-d>"]     = cmp.mapping.scroll_docs(4),
                ["<C-u>"]     = cmp.mapping.scroll_docs(-4),

                -- Phím Enter: Chỉ xác nhận nếu người dùng thực sự đang chọn 1 item
                ["<CR>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and cmp.get_selected_entry() then
                        cmp.confirm({ select = false })
                    else
                        fallback()
                    end
                end),

                -- Phím Tab (Theo thứ tự ưu tiên: Copilot -> Cmp -> Snippet -> Tab lùi lề)
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if has_copilot_suggestion() then
                        local accept = vim.fn["copilot#Accept"]("")
                        vim.api.nvim_feedkeys(accept, "n", true)
                        return
                    end
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                -- Phím Shift+Tab (Chỉ áp dụng cho Cmp và Snippet)
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
        })
    end,
}
