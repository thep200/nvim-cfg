# Neovim Config — Go-oriented, Lua, no Node

Cấu hình Neovim chuyển đổi từ cấu hình Vim cũ (`vim-plug` + `vim-lsp` + `nerdtree` + `airline` + `gitgutter` + `fzf` + `asyncomplete`), giữ nguyên:

- Theme custom **`zed_github_dark`** (bảng màu Zed editor).
- Toàn bộ phím tắt: `<C-b>`, `<C-p>`, `<leader>b/f/l`, `<S-Tab>`, LSP keymaps (`gd`, `gr`, `gi`, `gt`, `K`, `<leader>rn`, `<leader>ca`, `[d`, `]d`), cmp keymaps (`<Tab>`, `<S-Tab>`, `<CR>`, `<C-Space>`).
- Mọi cấu hình `gopls`: `staticcheck`, `gofumpt`, fuzzy matcher, analyses (unusedparams/shadow/nilness/unusedwrite/useany), inlay hints, auto-format + organize imports on save.
- Hành vi auto-save (`InsertLeave` / `FocusLost` / `BufLeave`), auto-reload, indent 4 space, search settings.

**Không** dùng plugin nặng phụ thuộc external: không `coc.nvim` (không cần Node), không Nerd Font icons.

---

## 1. Yêu cầu hệ thống

| Thành phần | Phiên bản tối thiểu | Ghi chú |
|---|---|---|
| **Neovim** | `0.10.0+` (khuyến nghị `0.11+`) | Cần `vim.lsp.inlay_hint`, `vim.uv` |
| **Git** | bất kỳ | Để `lazy.nvim` clone plugin |
| **Go toolchain** | `1.21+` | Cho `gopls`, `gofumpt` |
| **C compiler** | `gcc` / `clang` | Build `telescope-fzf-native` + parser treesitter |
| **make** | bất kỳ | Build `telescope-fzf-native` |
| **ripgrep** (`rg`) | bất kỳ | Cho `live_grep` của Telescope |
| **fd** (optional) | bất kỳ | Tăng tốc `find_files` |

### macOS

```bash
brew install neovim git go ripgrep fd
xcode-select --install   # gcc + make
```

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y neovim git golang-go ripgrep fd-find build-essential
# Lưu ý: trên Debian/Ubuntu, fd binary tên là 'fdfind' - symlink lại:
ln -s "$(which fdfind)" ~/.local/bin/fd
```

> ⚠️ Repo apt thường có Neovim cũ. Nếu `nvim --version` thấp hơn 0.10, cài qua [official prebuilt](https://github.com/neovim/neovim/releases) hoặc snap.

---

## 2. Cài đặt

### Bước 1. Backup config Neovim hiện tại (nếu có)

```bash
mv ~/.config/nvim                   ~/.config/nvim.bak.$(date +%s) 2>/dev/null
mv ~/.local/share/nvim              ~/.local/share/nvim.bak.$(date +%s) 2>/dev/null
mv ~/.local/state/nvim              ~/.local/state/nvim.bak.$(date +%s) 2>/dev/null
mv ~/.cache/nvim                    ~/.cache/nvim.bak.$(date +%s) 2>/dev/null
```

### Bước 2. Copy config

Copy nguyên thư mục này vào `~/.config/nvim`:

```bash
cp -r ./nvim-config ~/.config/nvim
```

Sau bước này, layout sẽ là:

```
~/.config/nvim/
├── init.lua
├── lua/
│   ├── core/
│   │   ├── options.lua
│   │   ├── keymaps.lua
│   │   ├── autocmds.lua
│   │   └── colorscheme.lua
│   └── plugins/
│       ├── init.lua
│       ├── neo-tree.lua
│       ├── lualine.lua
│       ├── gitsigns.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       ├── cmp.lua
│       └── lsp.lua
└── README.md
```

### Bước 3. Mở Neovim lần đầu

```bash
nvim
```

Lần đầu chạy, `lazy.nvim` sẽ:

1. Tự clone vào `~/.local/share/nvim/lazy/`.
2. Cài tất cả plugin (≈ 10–15 plugin) — đợi 1–2 phút.
3. Mở UI `:Lazy` hiển thị progress.

Sau khi `:Lazy` hiển thị `Loaded`, gõ `:q` để đóng.

### Bước 4. Cài LSP server cho Go

Mở 1 file `.go` bất kỳ:

```bash
nvim main.go
```

Mason sẽ tự động cài `gopls`. Theo dõi tiến trình bằng:

```vim
:Mason
```

Trong cửa sổ Mason, kiểm tra `gopls` đã có dấu `✓` ở mục **LSP**. Nếu chưa, nhấn `i` trên dòng `gopls` để install thủ công.

### Bước 5. Cài treesitter parsers (tự động, nhưng có thể kiểm tra)

Parser cho Go được cài tự động lần đầu mở file `.go`. Để kiểm tra:

```vim
:TSInstallInfo
```

`go`, `gomod`, `gosum` phải hiển thị `[✓] installed`.

---

## 3. Phím tắt — Quick reference

`<leader>` = **`Space`** (đã đổi từ default `\` cho thuận tay hơn).

### Navigation & Files

| Phím | Hành động | Plugin |
|---|---|---|
| `<C-b>` | Toggle file explorer (sidebar phải) | neo-tree |
| `<C-p>` | Find file trong project | telescope |
| `<S-Tab>` | Buffer kế tiếp | builtin |
| `<leader>b` | Liệt kê buffer đang mở | telescope |
| `<leader>f` | Grep toàn project (ripgrep) | telescope |
| `<leader>l` | Tìm dòng trong buffer hiện tại | telescope |
| `<Esc>` | Xoá highlight tìm kiếm | builtin |

### LSP (chỉ hoạt động trong file có LSP attach)

| Phím | Hành động |
|---|---|
| `gd` | Goto definition |
| `gr` | List references |
| `gi` | Goto implementation |
| `gt` | Goto type definition |
| `K` | Hover doc |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>e` | Hiện diagnostic của dòng hiện tại (popup) |
| `[d` / `]d` | Prev / Next diagnostic |
| `<leader>fd` | Diagnostics toàn workspace (telescope) |
| `<leader>fr` | LSP references (telescope picker) |
| `<leader>fs` | Symbols trong file |
| `<leader>fw` | Symbols toàn workspace |

### Autocomplete (insert mode)

| Phím | Hành động |
|---|---|
| `<Tab>` / `<S-Tab>` | Chọn item tiếp / trước trong popup |
| `<CR>` | Confirm item đang chọn |
| `<C-Space>` | Force refresh popup |
| `<C-e>` | Cancel popup |
| `<C-d>` / `<C-u>` | Scroll documentation |

### Git (gitsigns)

| Phím | Hành động |
|---|---|
| `]c` / `[c` | Next / Prev git hunk |
| `<leader>hp` | Preview hunk trong floating window |
| `<leader>hb` | Blame dòng hiện tại |
| `<leader>hr` | Reset hunk (vứt thay đổi) |
| `<leader>hs` | Stage hunk |
| `<leader>hu` | Undo stage hunk |
| `<leader>gs` | Telescope git status (file changed) |

### Treesitter (bonus)

| Phím | Hành động |
|---|---|
| `<C-Space>` (normal mode) | Incremental selection theo AST |
| `<BS>` | Shrink selection |

---

## 4. Tinh chỉnh

### Thêm ngôn ngữ LSP mới

Sửa `lua/plugins/lsp.lua`, thêm vào `ensure_installed`:

```lua
ensure_installed = {
    "gopls",
    "lua_ls",        -- ví dụ: thêm Lua LSP
    "pyright",       -- Python
},
```

Sau đó `setup` server mới (giống `lspconfig.gopls.setup`):

```lua
lspconfig.lua_ls.setup({
    capabilities = capabilities,
    on_attach    = on_attach,
})
```

### Thêm parser treesitter

Sửa `lua/plugins/treesitter.lua`, thêm vào `ensure_installed`:

```lua
ensure_installed = { "go", "rust", "python", ... }
```

### Tắt auto-save

Comment block `AutoSave` trong `lua/core/autocmds.lua`.

### Đổi vị trí file explorer sang trái

Sửa `lua/plugins/neo-tree.lua`, đổi `position = "right"` thành `position = "left"`.

### Đổi màu theme

Sửa palette `c = { ... }` ở đầu `lua/core/colorscheme.lua`.

---

## 5. Quản lý plugin

| Lệnh | Hành động |
|---|---|
| `:Lazy` | Mở UI quản lý plugin |
| `:Lazy sync` | Cập nhật + cài plugin mới |
| `:Lazy update` | Update tất cả plugin |
| `:Lazy clean` | Xoá plugin không còn khai báo |
| `:Lazy profile` | Xem startup time của từng plugin |
| `:Mason` | UI cài đặt LSP / formatter |
| `:checkhealth` | Kiểm tra cấu hình Neovim + plugin |

---

## 6. Troubleshooting

### gopls không attach vào file Go

```vim
:LspInfo
```

Nếu không thấy `gopls`, kiểm tra:

```bash
which gopls            # phải có trong PATH (nếu cài tự bằng go install)
ls ~/.local/share/nvim/mason/bin/gopls   # hoặc trong Mason
```

Mason cài binary vào `~/.local/share/nvim/mason/bin/` — nó tự thêm vào `$PATH` của Neovim, không cần config gì thêm.

### Telescope báo `fzf-native` build failed

Không sao — telescope vẫn chạy được, chỉ chậm hơn chút. Để fix, cần `gcc` + `make`, rồi:

```vim
:Lazy build telescope-fzf-native.nvim
```

### Treesitter báo parser error

```vim
:TSUpdate
```

Hoặc xoá hết parsers và cài lại:

```bash
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter/parser/
```

Rồi mở `nvim`, parsers sẽ tự cài lại.

### Auto-format không chạy khi save file Go

- Kiểm tra `:LspInfo` xem gopls có attach không.
- Kiểm tra `:messages` để xem có lỗi gì không.
- Có thể format thủ công: `:lua vim.lsp.buf.format()`.

### Màu hiển thị không đúng (trông như theme khác)

Terminal phải support **true color** (24-bit). Kiểm tra:

```bash
echo $COLORTERM   # phải in ra "truecolor" hoặc "24bit"
```

Nếu không: thêm vào `~/.zshrc` / `~/.bashrc`:

```bash
export COLORTERM=truecolor
```

Hoặc đổi sang terminal hỗ trợ tốt: iTerm2, Alacritty, WezTerm, Kitty.

---

## 7. Đối chiếu Vim cũ → Neovim mới

| Vim cũ | Neovim mới | Ghi chú |
|---|---|---|
| `~/.vim/vimrc` | `~/.config/nvim/init.lua` | Entry point |
| `~/.vim/config/general.vim` + `editor.vim` + `search.vim` | `lua/core/options.lua` | Options |
| `~/.vim/config/keymaps.vim` | `lua/core/keymaps.lua` + keymap trong từng plugin | Tách theo domain |
| `~/.vim/config/appearance.vim` | `lua/core/colorscheme.lua` | Theme port nguyên |
| `~/.vim/plugged/` | `~/.local/share/nvim/lazy/` | Plugin folder |
| vim-plug | lazy.nvim | Plugin manager |
| `:PlugInstall` | `:Lazy sync` | Cài plugin |
| `:LspInstallServer gopls` | Auto via Mason | Cài LSP |
| `:Files` | `:Telescope find_files` | Fuzzy file |
| `:Rg <text>` | `:Telescope live_grep` | Grep |
| `:NERDTreeToggle` | `:Neotree toggle` | File explorer |
| `:Gblame` (fugitive) | `<leader>hb` (gitsigns) | Git blame |

Plugin được **gỡ bỏ** so với cấu hình cũ:

- `Xuyuanp/nerdtree-git-plugin` → neo-tree tự có git status.
- `tpope/vim-fugitive` → lualine + gitsigns lo branch/blame.
- `mattn/vim-lsp-settings` → mason.nvim làm tốt hơn.
- `asyncomplete-lsp.vim` → cmp-nvim-lsp.

Plugin được **thêm mới** (cần thiết cho stack mới):

- `nvim-treesitter` — để theme `zed_github_dark` map đúng capture group, highlight Go chuẩn.
- `LuaSnip` + `cmp_luasnip` — snippet engine bắt buộc cho `nvim-cmp`.
- `plenary.nvim`, `nui.nvim` — thư viện util chung của hệ sinh thái.



