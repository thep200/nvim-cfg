;; extends

; Dấu bao chuỗi tô màu riêng (@string.delimiter), nội dung chuỗi giữ màu @string.
; priority 130: thắng cả semantic token của LSP (125) vốn tô nguyên chuỗi.
(quoted_attribute_value ["\"" "'"] @string.delimiter (#set! priority 130))
