-- ============================================================
--  languages/init.lua
-- ============================================================

local M = {}

M.languages = {
    go = {
        lsp = "languages.go.gopls",
        dap = "languages.go.dap",
    },

    -- python = {
    --     lsp = "languages.python.pyright",
    --     dap = "languages.python.dap",
    -- },
}

-- ------------------------------------------------------------
-- Helper: load tất cả module config theo feature ("lsp" | "dap")
-- ------------------------------------------------------------
local function collect(feature)
    local out = {}
    for lang, spec in pairs(M.languages) do
        local modpath = spec[feature]
        if modpath then
            local ok, mod = pcall(require, modpath)
            if ok and type(mod) == "table" then
                mod._lang = lang
                table.insert(out, mod)
            else
                vim.notify(
                    ("[languages] Không load được %q: %s"):format(modpath, mod),
                    vim.log.levels.WARN
                )
            end
        end
    end
    return out
end

function M.lsp() return collect("lsp") end
function M.dap() return collect("dap") end

-- Danh sách server cần cài qua mason-lspconfig (ensure_installed)
function M.mason_lsp_servers()
    local servers = {}
    for _, cfg in ipairs(M.lsp()) do
        for _, name in ipairs(cfg.mason or {}) do
            table.insert(servers, name)
        end
    end
    return servers
end

-- Dependencies (plugin) bổ sung cho nvim-dap
function M.dap_dependencies()
    local deps = {}
    for _, cfg in ipairs(M.dap()) do
        for _, dep in ipairs(cfg.dependencies or {}) do
            table.insert(deps, dep)
        end
    end
    return deps
end

-- Filetypes để lazy-load nvim-dap (union của các ngôn ngữ đã bật)
function M.dap_ft()
    local fts = {}
    for _, cfg in ipairs(M.dap()) do
        for _, ft in ipairs(cfg.ft or {}) do
            table.insert(fts, ft)
        end
    end
    return fts
end

return M
