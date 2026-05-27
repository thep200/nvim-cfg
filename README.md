# Neovim Config

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

## NVim keyboards

## 1. Vertical Navigation

| Phím tắt | Thao tác | Giải thích chi tiết ngữ cảnh sử dụng |
| :--- | :--- | :--- |
| `Ctrl` + `d` | **Down Half Page** | Cuộn màn hình xuống dưới nửa trang. Lướt nhanh cấu trúc file mà không mất dấu dòng code. |
| `Ctrl` + `u` | **Up Half Page** | Cuộn màn hình lên trên nửa trang. Giúp định vị lại các khối hàm phía trên nhanh chóng. |
| `{` | **Jump Paragraph Up** | Nhảy con trỏ lên dòng trống phía trên. Cực nhanh khi muốn nhảy qua lại giữa các hàm `func`. |
| `}` | **Jump Paragraph Down**| Nhảy con trỏ xuống dòng trống phía dưới. Vượt qua nhanh các khối logic ngắn. |
| `[Số]` + `j` | **Relative Jump Down** | Nhảy xuống chính xác số dòng dựa theo số dòng tương đối hiển thị ở rìa màn hình (Ví dụ: `12j`). |
| `[Số]` + `k` | **Relative Jump Up** | Nhảy lên chính xác số dòng dựa theo số dòng tương đối hiển thị ở rìa màn hình (Ví dụ: `5k`). |
| `gg` | **Go to Top** | Đưa con trỏ ngay lập tức về dòng đầu tiên của file (thường để check gói `package` hoặc `import`). |
| `G` | **Go to Bottom** | Đưa con trỏ ngay lập tức xuống dòng cuối cùng của file (thường để ghi thêm hàm mới). |
| `%` | **Match Pair** | Di chuyển qua lại giữa các dấu đóng/mở của cặp ngoặc `()`, `{}`, `[]`. Chuyên trị lỗi block code trong Go. |

---

### 2. Built-in Commenting

> Lưu ý: Tính năng này chạy trực tiếp trên lõi Neovim 0.10+ mà không cần cài thêm bất kỳ plugin bên thứ ba nào.*

| Phím tắt | Chế độ (Mode) | Giải thích chi tiết & Cách thực hiện |
| :--- | :--- | :--- |
| `gcc` | **Normal Mode** | Bật/Tắt comment (Toggle Comment) duy nhất **một dòng hiện tại** nơi con trỏ đang đứng. |
| `gc` | **Visual Mode** | **Comment cả block chọn:** Nhấn `V` để bôi đen nhiều dòng code, sau đó nhấn `gc` để đóng dấu `//` toàn bộ. |
| `gcap` | **Normal Mode** | **Comment cả đoạn (Paragraph):** Tự động comment toàn bộ khối code viết liền nhau (đến khi gặp dòng trống). |

---

### 3. Yank & Paste

> Yêu cầu cấu hình hệ thống đã bật tính năng: `vim.opt.clipboard = "unnamedplus"` để chia sẻ chung dữ liệu với phím `Cmd+V` bên ngoài máy.*

| Phím tắt | Thao tác | Giải thích chi tiết ngữ cảnh sử dụng |
| :--- | :--- | :--- |
| `yy` | **Yank Line** | Copy nguyên cả dòng nơi con trỏ đang đứng vào bộ nhớ hệ thống. |
| `yw` | **Yank Word** | Copy 1 từ tính từ vị trí con trỏ hiện tại sang bên phải. |
| `y$` | **Yank to End** | Copy từ vị trí con trỏ hiện tại cho đến khi chạm cuối dòng. |
| `yi{` | **Yank Inside `{}`**| **Quyền năng:** Copy toàn bộ nội dung nằm bên trong cặp ngoặc nhọn (Ví dụ: nội dung struct, thân hàm Go). |
| `v` + `y` | **Visual Yank** | Nhấn `v` để bôi đen thủ công vùng chữ tùy chọn, sau đó nhấn `y` để kết thúc việc Copy. |
| `p` | **Paste Below** | Dán nội dung đã copy xuống **phía dưới** dòng hiện tại hoặc phía sau con trỏ chuột. |
| `P` *(Shift+p)*| **Paste Above** | Dán nội dung đã copy lên **phía trên** dòng hiện tại hoặc phía trước con trỏ chuột. |

---
