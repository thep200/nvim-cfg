# Neovim Config

Cấu hình Neovim tối giản, ưu tiên hiệu năng cho Go developer. Không phụ thuộc Nerd Font, không icon loè loẹt, hạn chế plugin nặng.

---

## 1. Yêu cầu hệ thống

| Thành phần | Phiên bản tối thiểu | Ghi chú |
|---|---|---|
| **Neovim** | `0.10.0+` (khuyến nghị `0.11+`) | Cần `vim.lsp.inlay_hint`, `vim.uv` |
| **Git** | bất kỳ | Để `lazy.nvim` clone plugin |
| **Go toolchain** | `1.21+` | Cho `gopls`, `gofumpt` |
| **Node.js** | `18+` | Yêu cầu của GitHub Copilot |
| **C compiler** | `gcc` / `clang` | Build `telescope-fzf-native` + parser treesitter |
| **make** | bất kỳ | Build `telescope-fzf-native` |
| **ripgrep** (`rg`) | bất kỳ | Cho `live_grep` của Telescope |
| **fd** (optional) | bất kỳ | Tăng tốc `find_files` |

### macOS

```bash
brew install neovim git go node ripgrep fd
xcode-select --install   # gcc + make
```

### Tricky

> Convert `Caps Lock` into `Ctrl`

---

## 2. Phím tắt - Hệ thống (Built-in Neovim)

> Các phím tắt mặc định của Neovim, không cần plugin. Sử dụng để di chuyển, chỉnh sửa và thao tác văn bản cơ bản.

**Leader key**: `Space`

### 2.1 Vertical Navigation

| Phím tắt | Thao tác | Giải thích chi tiết ngữ cảnh sử dụng |
| :--- | :--- | :--- |
| `Ctrl` + `d` | **Down Half Page** | Cuộn màn hình xuống dưới nửa trang. Lướt nhanh cấu trúc file mà không mất dấu dòng code. |
| `Ctrl` + `u` | **Up Half Page** | Cuộn màn hình lên trên nửa trang. Giúp định vị lại các khối hàm phía trên nhanh chóng. |
| `{` | **Jump Paragraph Up** | Nhảy con trỏ lên dòng trống phía trên. Cực nhanh khi muốn nhảy qua lại giữa các hàm `func`. |
| `}` | **Jump Paragraph Down** | Nhảy con trỏ xuống dòng trống phía dưới. Vượt qua nhanh các khối logic ngắn. |
| `[Số]` + `j` | **Relative Jump Down** | Nhảy xuống chính xác số dòng dựa theo số dòng tương đối hiển thị ở rìa màn hình (Ví dụ: `12j`). |
| `[Số]` + `k` | **Relative Jump Up** | Nhảy lên chính xác số dòng dựa theo số dòng tương đối hiển thị ở rìa màn hình (Ví dụ: `5k`). |
| `gg` | **Go to Top** | Đưa con trỏ ngay lập tức về dòng đầu tiên của file (thường để check gói `package` hoặc `import`). |
| `G` | **Go to Bottom** | Đưa con trỏ ngay lập tức xuống dòng cuối cùng của file (thường để ghi thêm hàm mới). |
| `%` | **Match Pair** | Di chuyển qua lại giữa các dấu đóng/mở của cặp ngoặc `()`, `{}`, `[]`. Chuyên trị lỗi block code trong Go. |
| `H` / `M` / `L` | **Top / Middle / Bottom of Screen** | Nhảy đến đầu / giữa / cuối **vùng nhìn thấy** trên màn hình. |
| `zz` / `zt` / `zb` | **Center / Top / Bottom Cursor** | Cuộn để đưa dòng hiện tại về giữa / đầu / cuối màn hình. |

### 2.2 Horizontal Navigation

| Phím tắt | Thao tác | Giải thích |
| :--- | :--- | :--- |
| `w` / `W` | **Next Word / WORD** | Nhảy đến đầu từ tiếp theo (`W` không phân biệt dấu chấm câu). |
| `b` / `B` | **Prev Word / WORD** | Nhảy đến đầu từ trước đó. |
| `e` / `E` | **End of Word** | Nhảy đến cuối từ hiện tại. |
| `0` | **Line Start** | Nhảy về ký tự đầu tiên của dòng. |
| `^` | **First Non-blank** | Nhảy đến ký tự đầu tiên không phải khoảng trắng. |
| `$` | **Line End** | Nhảy đến cuối dòng. |
| `f` + `[Ký tự]` | **Find Forward** | Nhảy đến lần xuất hiện tiếp theo của ký tự trong dòng. `;` lặp lại, `,` ngược lại. |
| `t` + `[Ký tự]` | **Till Forward** | Nhảy đến **trước** ký tự đó (hữu ích cho `dt;`, `ct,`). |

### 2.3 Built-in Commenting

> Tính năng này chạy trực tiếp trên lõi Neovim 0.10+ mà không cần plugin bên thứ ba.

| Phím tắt | Chế độ (Mode) | Giải thích chi tiết & Cách thực hiện |
| :--- | :--- | :--- |
| `gcc` | **Normal Mode** | Bật/Tắt comment (Toggle Comment) duy nhất **một dòng hiện tại** nơi con trỏ đang đứng. |
| `gc` | **Visual Mode** | **Comment cả block chọn:** Nhấn `V` để bôi đen nhiều dòng code, sau đó nhấn `gc` để đóng dấu `//` toàn bộ. |
| `gcap` | **Normal Mode** | **Comment cả đoạn (Paragraph):** Tự động comment toàn bộ khối code viết liền nhau (đến khi gặp dòng trống). |

### 2.4 Yank & Paste

> Đã bật `vim.opt.clipboard = "unnamedplus"` để chia sẻ chung dữ liệu với phím `Cmd+V` bên ngoài máy.

| Phím tắt | Thao tác | Giải thích chi tiết ngữ cảnh sử dụng |
| :--- | :--- | :--- |
| `yy` | **Yank Line** | Copy nguyên cả dòng nơi con trỏ đang đứng vào bộ nhớ hệ thống. |
| `yw` | **Yank Word** | Copy 1 từ tính từ vị trí con trỏ hiện tại sang bên phải. |
| `y$` | **Yank to End** | Copy từ vị trí con trỏ hiện tại cho đến khi chạm cuối dòng. |
| `yi{` | **Yank Inside `{}`** | **Quyền năng:** Copy toàn bộ nội dung nằm bên trong cặp ngoặc nhọn (Ví dụ: nội dung struct, thân hàm Go). |
| `v` + `y` | **Visual Yank** | Nhấn `v` để bôi đen thủ công vùng chữ tùy chọn, sau đó nhấn `y` để kết thúc việc Copy. |
| `p` | **Paste Below** | Dán nội dung đã copy xuống **phía dưới** dòng hiện tại hoặc phía sau con trỏ chuột. |
| `P` *(Shift+p)* | **Paste Above** | Dán nội dung đã copy lên **phía trên** dòng hiện tại hoặc phía trước con trỏ chuột. |
| `"+y` / `"+p` | **System Clipboard** | Yank / Paste tường minh với clipboard hệ thống (dùng khi không bật `unnamedplus`). |

### 2.5 Replace & Substitute

| Phím tắt / Lệnh | Thao tác | Giải thích chi tiết ngữ cảnh sử dụng |
| --- | --- | --- |
| `r` + `[Ký tự]` | **Replace Character** | Thay thế duy nhất 1 ký tự ngay dưới con trỏ bằng ký tự mới. Vẫn giữ nguyên trạng thái Normal Mode. |
| `R` | **Replace Mode** | Vào chế độ ghi đè (giống phím Insert trên bàn phím). Gõ đến đâu đè và xóa chữ cũ đến đó. Nhấn `Esc` để thoát. |
| `~` | **Toggle Case** | Đổi nhanh ký tự dưới con trỏ từ viết thường thành viết hoa hoặc ngược lại. |
| `cw` | **Change Word** | Xóa từ vị trí con trỏ đến hết từ hiện tại và tự động chuyển sang Insert Mode để gõ chữ mới. |
| `ciw` | **Change Inside Word** | Đứng ở bất kỳ vị trí nào trong từ, nhấn tổ hợp này để xóa sạch từ đó và chuyển sang Insert Mode gõ từ mới. |
| `ci{` | **Change Inside `{}`** | Xóa sạch ruột bên trong cặp ngoặc nhọn `{}` và đưa bạn vào Insert Mode để viết lại logic mới. |
| `ci"` / `ci'` | **Change Inside Quotes** | Xóa nội dung bên trong cặp dấu nháy và vào Insert Mode (hữu ích sửa string). |
| `:s/cũ/mới/g` | **Substitute in Line** | Tìm các cụm từ cũ và đổi sang cụm từ mới chỉ trong phạm vi **dòng hiện tại**. |
| `:%s/cũ/mới/g` | **Substitute in File** | Tìm và thay thế hàng loạt cụm từ trong **toàn bộ file**. |
| `:%s/cũ/mới/gc` | **Substitute (Confirm)** | Thay thế toàn file nhưng **hỏi xác nhận** từng vị trí (`y`: Đồng ý, `n`: Bỏ qua, `a`: Thay thế tất, `Esc`: Thoát). Rất an toàn. |
| `:'<,'>s/cũ/mới/g` | **Visual Substitute** | Nhấn `V` bôi đen một vùng trước, sau đó gõ lệnh để thay thế giới hạn **chỉ trong vùng được bôi đen**. |

### 2.6 Selection & Deletion

| Phím tắt | Thao tác | Giải thích chi tiết ngữ cảnh sử dụng |
| --- | --- | --- |
| `ggVG` | **Chọn tất cả** (Select All) | Nhảy về đầu file (`gg`), bật chế độ bôi đen dòng (`V`), nhảy xuống cuối file (`G`). Thường dùng để copy toàn bộ code. |
| `ggdG` | **Xóa tất cả** (Delete All) | Nhảy về đầu file (`gg`), xóa (`d`) đến tận cuối file (`G`). Xóa sạch nội dung hiện tại. |
| `:%d` + `Enter` | **Xóa tất cả** (Lệnh) | Lệnh xóa dứt khoát và sạch sẽ toàn bộ phạm vi file (`%`) từ Command Mode. |
| `vi{` / `va{` | **Bôi đen khối ngoặc** `{}` | Bôi đen bên trong (`i`) hoặc bao gồm cả vỏ (`a`) của cặp ngoặc nhọn. Chuyên trị các hàm, struct, interface. |
| `di{` / `da{` | **Xóa khối ngoặc** `{}` | Xóa sạch ruột để viết lại logic (`di{`) hoặc xóa bay màu toàn bộ hàm bao gồm cả ngoặc (`da{`). |
| `vip` / `vap` | **Bôi đen đoạn văn** | Chọn nhanh khối code viết liền nhau (không có dòng trống ở giữa). |
| `dip` / `dap` | **Xóa đoạn văn** | Xóa sạch cụm xử lý logic liền nhau chỉ trong một thao tác. |
| `V` + `[số]j` | **Bôi đen n dòng** | Kết hợp bật Visual Mode (`V`) và số dòng tương đối (`j`) để bôi đen chính xác lượng code bên dưới. |
| `d` + `[số]j` | **Xóa n dòng** | Cắt phăng nhanh chóng một số lượng dòng cố định bên dưới con trỏ mà không cần bôi đen trước. |
| `d` / `x` / `y` | **Xóa / Copy vùng chọn** | Sau khi dùng lệnh bôi đen (`vi{`, `vip`...), nhấn `d` hoặc `x` để xóa, nhấn `y` để copy vùng đó. |
| `>>` / `<<` | **Indent / Dedent** | Thụt lề / lùi lề dòng hiện tại (4 spaces theo config). Trong Visual Mode dùng `>` và `<`. |

### 2.7 Undo, Search & Misc

| Phím tắt | Thao tác | Giải thích |
| --- | --- | --- |
| `u` | **Undo** | Hoàn tác lại thao tác vừa thực hiện. |
| `Ctrl + r` | **Redo** | Đi tiếp (khôi phục lại) hành động vừa bị Undo. |
| `/` + `từ khóa` | **Tìm kiếm xuôi** | Tìm từ khóa xuống dưới file. Nhấn `n` để đi tiếp kết quả, `N` để quay ngược lại. |
| `?` + `từ khóa` | **Tìm kiếm ngược** | Như `/` nhưng tìm ngược lên. |
| `*` | **Tìm nhanh biến/hàm** | Đặt con trỏ tại biến hoặc hàm và nhấn `*`, Neovim tự động tìm mọi vị trí xuất hiện của từ đó. |
| `#` | **Tìm nhanh ngược** | Như `*` nhưng tìm ngược lên. |
| `.` | **Repeat Last Change** | Lặp lại thao tác chỉnh sửa cuối cùng - **cực mạnh** kết hợp với `f`, `t`, `n`. |
| `:w` / `:wq` / `:q!` | **Save / Save+Quit / Force Quit** | Lưu file / Lưu rồi thoát / Thoát không lưu. |
| `:e <file>` | **Edit File** | Mở file mới trong buffer hiện tại. |
| `:bd` | **Buffer Delete** | Đóng buffer hiện tại. |

---

## 3. Phím tắt - Custom (từ `core/keymaps.lua`)

> Các phím tắt do người dùng tự định nghĩa, ghi đè hoặc bổ sung hành vi mặc định.

### 3.1 Buffer & Search

| Phím tắt | Thao tác | Giải thích |
| :--- | :--- | :--- |
| `Shift + Tab` | **Next Buffer** | Chuyển sang buffer tiếp theo (`:bnext`). |
| `Esc` | **Clear Search Highlight** | Tắt highlight kết quả tìm kiếm sau khi search xong (`:nohlsearch`). |

### 3.2 Window Split & Navigation

| Phím tắt | Thao tác | Giải thích |
| :--- | :--- | :--- |
| `Ctrl + Shift + ↑` | **Horizontal Split** | Chia màn hình theo chiều ngang (`:split`). |
| `Ctrl + Shift + ↓` | **Horizontal Split** | Chia màn hình theo chiều ngang (`:split`). |
| `Ctrl + Shift + ←` | **Vertical Split** | Chia màn hình theo chiều dọc (`:vsplit`). |
| `Ctrl + Shift + →` | **Vertical Split** | Chia màn hình theo chiều dọc (`:vsplit`). |
| `Shift + ↑` | **Window Up** | Di chuyển con trỏ sang cửa sổ phía trên. |
| `Shift + ↓` | **Window Down** | Di chuyển con trỏ sang cửa sổ phía dưới. |
| `Shift + ←` | **Window Left** | Di chuyển con trỏ sang cửa sổ bên trái. |
| `Shift + →` | **Window Right** | Di chuyển con trỏ sang cửa sổ bên phải. |

---

## 4. Phím tắt - Plugin (Function)

### 4.1 Neo-tree (File Explorer)

> Quản lý cây thư mục bên phải màn hình. Toggle bằng `Ctrl + b`.

**Phím tắt trong cửa sổ Neo-tree:**

| Phím tắt | Thao tác | Giải thích |
| :--- | :--- | :--- |
| `Enter` / `l` | **Open / Toggle** | Mở file (nhảy con trỏ sang), hoặc đóng/mở thư mục. |
| `space` | **Preview** | Mở file nhưng giữ nguyên con trỏ ở Neo-tree (lướt xem nhanh). |
| `s` | **Open Split** | Mở file và chia đôi màn hình theo chiều ngang. |
| `v` | **Open VSplit** | Mở file và chia đôi màn hình theo chiều dọc (so sánh code song song). |
| `t` | **Open Tab** | Mở file trong tab mới. |
| `a` | **Add** | Tạo file/folder mới. Thêm `/` cuối để là folder (VD: `repo/`). Có thể tạo chuỗi `cmd/api/main.go`. |
| `r` | **Rename** | Đổi tên file/folder. |
| `d` | **Delete** | Xóa file/folder (luôn có prompt xác nhận `[y/N]`). |
| `x` | **Cut** | Chọn file/folder để di chuyển. File sẽ mờ đi báo hiệu đang nằm trong bộ nhớ đệm. |
| `c` | **Copy** | Chọn file/folder để nhân bản. |
| `p` | **Paste** | Dán file đã Cắt/Copy vào thư mục hiện tại. |
| `H` | **Toggle Hidden** | Bật/tắt hiển thị file ẩn (`.dotfiles`). |
| `R` | **Refresh** | Làm mới cây thư mục khi có thay đổi từ bên ngoài. |
| `q` | **Close Window** | Đóng Neo-tree. |
| `?` | **Help** | Mở bảng tra cứu nhanh toàn bộ phím tắt nội bộ. |

### 4.2 Telescope (Fuzzy Finder)

> Tìm kiếm file, buffer, symbol, git, ... toàn dự án.

**Find / Search:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `<leader>ff` | **Find Files** - Tìm file trong dự án |
| `<leader>fb` | **Find Buffers** - Liệt kê buffer đang mở |
| `<leader>fg` | **Live Grep** - Tìm theo nội dung (toàn dự án) |
| `<leader>fl` | **Buffer Lines** - Tìm dòng trong buffer hiện tại |
| `<leader>fh` | **Help Tags** - Tìm trong tài liệu Neovim |
| `<leader>fk` | **Keymaps** - Liệt kê toàn bộ phím tắt đã đăng ký |
| `<leader>fo` | **Recent Files** - Mở lại file vừa làm việc |

**LSP Pickers:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `<leader>fd` | **Diagnostics** - Liệt kê toàn bộ lỗi/cảnh báo |
| `<leader>fr` | **LSP References** - Liệt kê nơi gọi tới symbol |
| `<leader>fs` | **Document Symbols** - Liệt kê symbol trong file |
| `<leader>fw` | **Workspace Symbols** - Liệt kê symbol toàn workspace |

**Git Pickers:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `<leader>gs` | **Git Status** - File nào đã đổi |
| `<leader>gc` | **Git Commits** - Lịch sử commit |
| `<leader>gb` | **Git Branches** - Danh sách branch |

**Phím tắt bên trong Telescope:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `Ctrl + t` | Mở kết quả trong tab mới |
| `Ctrl + x` | Mở kết quả trong split ngang |
| `Ctrl + v` | Mở kết quả trong split dọc |
| `Ctrl + q` | Gửi toàn bộ kết quả vào Quickfix list |
| `Esc` | Đóng Telescope |

### 4.3 LSP (gopls)

> Phím tắt chỉ kích hoạt khi LSP attach vào buffer.

| Phím tắt | Thao tác | Giải thích |
| :--- | :--- | :--- |
| `gd` | **Goto Definition** | Nhảy đến nơi định nghĩa hàm/biến (qua Telescope). |
| `gr` | **References** | Liệt kê tất cả nơi gọi tới symbol. |
| `gi` | **Goto Implementation** | Nhảy đến nơi implement interface. |
| `gt` | **Goto Type Definition** | Nhảy đến định nghĩa type. |
| `K` | **Hover Documentation** | Xem doc của hàm/biến dưới con trỏ. Nhấn `K` lần 2 để vào float window. |
| `<leader>rn` | **Rename Symbol** | Đổi tên symbol toàn workspace (safe refactor). |
| `<leader>ca` | **Code Action** | Hiện menu hành động code (fix import, generate, ...). |
| `[d` | **Prev Diagnostic** | Nhảy đến lỗi/cảnh báo trước đó. |
| `]d` | **Next Diagnostic** | Nhảy đến lỗi/cảnh báo tiếp theo. |
| `<leader>e` | **Show Line Diagnostic** | Hiện chi tiết diagnostic của dòng hiện tại (float). |

### 4.4 Gitsigns

> Chỉ kích hoạt trong file thuộc Git repo.

**Hunk Navigation:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `]c` | **Next Git Hunk** - Nhảy đến đoạn code đã thay đổi tiếp theo |
| `[c` | **Prev Git Hunk** - Nhảy đến đoạn code đã thay đổi trước đó |

**Hunk Actions:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `<leader>hp` | **Preview Hunk** - Xem code cũ/mới của đoạn này |
| `<leader>hr` | **Reset Hunk** - Hủy thay đổi của đoạn này |
| `<leader>hs` | **Stage Hunk** - Đưa đoạn này vào commit |
| `<leader>hu` | **Undo Stage Hunk** - Hoàn tác việc stage |
| `<leader>hb` | **Blame Line** - Xem ai sửa dòng này (full info) |

**Buffer-wide:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `<leader>gd` | **Git Diff** - So sánh toàn file với HEAD |
| `<leader>gR` | **Git Reset Buffer** - Hủy toàn bộ thay đổi file |

> Lưu ý: `<leader>gs`, `<leader>gc`, `<leader>gb` thuộc Telescope (xem mục 4.2).

### 4.5 nvim-cmp (Completion)

> Autocomplete trong Insert Mode. Tích hợp LSP + LuaSnip + Buffer + Path + Copilot.

| Phím tắt | Thao tác | Giải thích |
| :--- | :--- | :--- |
| `Ctrl + Space` | **Trigger Complete** | Mở popup gợi ý thủ công. |
| `Tab` | **Accept / Next** | Ưu tiên: Copilot → Cmp item → Snippet jump → Tab thường. |
| `Shift + Tab` | **Prev Item / Snippet Back** | Chọn item phía trên hoặc nhảy ngược placeholder. |
| `Enter` | **Confirm Selection** | Chỉ xác nhận nếu thật sự đang chọn 1 item (tránh confirm nhầm). |
| `Ctrl + e` | **Abort** | Đóng popup, hủy gợi ý. |
| `Ctrl + d` | **Scroll Docs Down** | Cuộn nội dung doc trong popup. |
| `Ctrl + u` | **Scroll Docs Up** | Cuộn doc lên. |

### 4.6 GitHub Copilot

> Ghost text AI. Phím `Tab` đã được nhường cho nvim-cmp (xem mục 4.5).

| Phím tắt | Thao tác | Giải thích |
| :--- | :--- | :--- |
| `Ctrl + j` | **Accept Suggestion** | Backup khi nvim-cmp lỗi/tắt. Nhận full suggestion. |
| `Ctrl + l` | **Accept Next Word** | Nhận từng từ một (kiểm soát code AI tốt hơn). |

### 4.7 DAP - Debug Adapter (Go via delve)

> Chỉ kích hoạt khi mở file Go.

**Flow Control:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `F5` | **Continue / Start** |
| `F10` | **Step Over** |
| `F11` | **Step Into** |
| `F12` | **Step Out** |

**Breakpoints:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `<leader>db` | **Toggle Breakpoint** |
| `<leader>dB` | **Conditional Breakpoint** - Có prompt nhập điều kiện |
| `<leader>dL` | **Log Point** - Có prompt nhập log message |

**Session:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `<leader>dc` | **Continue / Start** (alias của F5) |
| `<leader>dr` | **Open REPL** |
| `<leader>dl` | **Run Last Session** |
| `<leader>dq` | **Terminate Session** |
| `<leader>du` | **Toggle DAP UI** |
| `<leader>de` | **Eval Expression** - n/v mode (biến dưới con trỏ / selection) |

**Go-specific:**

| Phím tắt | Thao tác |
| :--- | :--- |
| `<leader>dt` | **Debug Nearest Test** |
| `<leader>dT` | **Debug Last Test** |

### 4.8 Treesitter (Incremental Selection)

| Phím tắt | Thao tác | Giải thích |
| :--- | :--- | :--- |
| `Ctrl + Space` | **Init / Expand Selection** | Bắt đầu chọn node hiện tại, nhấn tiếp để mở rộng theo AST. |
| `Backspace` | **Shrink Selection** | Thu nhỏ lại 1 cấp. |

> ⚠ Phím `Ctrl + Space` đụng với `nvim-cmp` (trigger complete). Treesitter chỉ kích hoạt trong Normal/Visual Mode nên không xung đột thực tế.

### 4.9 Which-key

| Phím tắt | Thao tác |
| :--- | :--- |
| `<leader>?` | Hiện toàn bộ keymap của buffer hiện tại |
| `<leader>` *(chờ 400ms)* | Tự động popup các keymap bắt đầu bằng leader |

**Group prefix đã đăng ký:**

| Prefix | Nhóm |
| :--- | :--- |
| `<leader>f` | Find / Telescope |
| `<leader>h` | Git Hunks (gitsigns) |
| `<leader>c` | Code (LSP) |
| `<leader>r` | Rename / Refactor |
| `<leader>g` | Git |
| `<leader>d` | Debug (DAP) |
| `[` | Prev ... |
| `]` | Next ... |
| `g` | Goto ... |

---

## 5. Sử dụng terminal

| Bước | Phím tắt / Lệnh | Mục đích |
| :--- | :--- | :--- |
| **CÁCH 1: SINGLE COMMAND** | | |
| Bước 1 | Nhấn `Esc` | Đưa editor về chế độ **Normal Mode** trước khi gõ lệnh. |
| Bước 2 | `:! [câu_lệnh]` <br>*(Ví dụ: `:!go run main.go` hoặc `:!git status`)* | Chạy nhanh một lệnh hệ thống duy nhất, xem kết quả hiển thị tạm thời trên màn hình. |
| Bước 3 | Nhấn `Enter` | Thoát màn hình kết quả lệnh và quay trở lại giao diện code nguyên vẹn ngay lập tức. |
| | | |
| **CÁCH 2: EMBEDDED TERMINAL** | | |
| Bước 1 | `:terminal` <br>*(Gõ tắt: `:term`)* | Khởi tạo một cửa sổ Terminal độc lập toàn màn hình ngay bên trong Neovim. |
| Mẹo nâng cao | `:vsplit \| terminal` <br> `:split \| terminal` | Chia đôi màn hình theo chiều dọc (phải) hoặc chiều ngang (dưới) rồi mở Terminal để vừa code vừa chạy server song song. |
| Bước 2 | Nhấn phím `i` | Chuyển sang **Terminal Mode** để bắt đầu tương tác, gõ lệnh, tận dụng phím `Tab` gợi ý của Oh My Zsh. |
| Bước 3 | Nhấn `Ctrl + \` rồi nhấn tiếp `Ctrl + N` | Thoát chế độ gõ lệnh của Terminal để quay về **Normal Mode**, giúp di chuyển con trỏ chuột ra ngoài ô code hoặc gõ `:bd!` để đóng Terminal. |
| | | |
| **CÁCH 3: SUSPEND TO BACKGROUND** | | |
| Bước 1 | Nhấn `Ctrl + Z` | Thực hiện ở Normal Mode để đẩy toàn bộ Neovim vào trạng thái chạy ngầm (Suspended) và trả bạn về lại Ghostty Terminal thường. |
| Bước 2 | Thao tác lệnh tự do trên Ghostty | Thực hiện chuỗi các tác vụ nặng bên ngoài hệ thống (như build Docker, check log hệ thống lớn...). |
| Bước 3 | Gõ lệnh `fg` và nhấn `Enter` | Đưa Neovim từ nền chạy ngầm quay trở lại tiền cảnh (Foreground), giữ nguyên trạng thái và đúng dòng code bạn đang gõ dở trước đó. |

---



## 6. Tham khảo nhanh - Workflow Substitute toàn dự án

| Bước | Phím tắt / Lệnh | Mục đích |
| --- | --- | --- |
| 1 | `<leader>fg` | Mở Telescope Grep tìm cụm từ cần đổi |
| 2 | `Ctrl + q` | Gửi toàn bộ kết quả vào Quickfix list |
| 3 | `:cdo s/cũ/mới/g \| update` | Thay thế trong tất cả file của Quickfix và auto-save |
