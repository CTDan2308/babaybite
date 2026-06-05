# Changelog

Tất cả thay đổi đáng chú ý của dự án **BaBayBite** sẽ được ghi ở đây.

Format theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/), tuân thủ [Semantic Versioning](https://semver.org/lang/vi/).

---

## [1.15.0] — 2026-06-05 (+07)

🛵 **KPI Shipper · QR thu tiền · Âm thanh báo đơn · Tối ưu UI Trực đơn**

### Added
- **Bảng lương / KPI Shipper (cả đợt):**
  - Màn Giao hàng (trưởng ca/admin): bảng **"Lương Shipper cả đợt"** — mỗi shipper: số đơn giao, tổng phí ship,
    thưởng, **tổng giải ngân**. Phục vụ giải ngân cuối đợt.
  - ShipperApp: thêm tab **"KPI / Lương"** — tổng giải ngân dự kiến + breakdown + chi tiết từng đơn.
  - Công thức: `tổng phí ship đơn đã giao + thưởng × số đơn` (thưởng/đơn cấu hình trong Cài đặt, mặc định 0).
- **Nút QR thu tiền cho Shipper:** trên card đơn → modal **VietQR động** (img.vietqr.io), số tiền mặc định =
  tổng đơn (sửa được). Tài khoản nhận tiền cấu hình ở **Cài đặt → Cài đặt chung → Tài khoản nhận tiền (VietQR)**
  (ngân hàng + STK + tên chủ TK), lưu DB dùng chung mọi thiết bị.
- **Âm thanh + hiệu ứng động báo đơn:** đơn mới (pha chế) & đơn được giao (shipper) phát **tiếng beep** +
  **overlay động** giữa màn. Nút bật/tắt 🔊 ở TopBar / header pha chế / header shipper (option, mặc định bật).
- **Bảng `app_config`** (DB): lưu cấu hình VietQR + thưởng shipper. Có cờ phát hiện mềm `CONFIG_DB_OK`
  (app chạy bình thường nếu chưa migrate, chỉ tạm khoá QR/cấu hình).

### Changed
- **Tối ưu UI Trực đơn:** thêm **ô tìm kiếm** (mã đơn / khách / SĐT) + **chip lọc theo trạng thái** cho
  "Đơn đang xử lý" → giảm sót/sai đơn khi số lượng lớn. Mục **Đặt trước** giữ tách riêng, sắp gần→xa.

---

## [1.14.0] — 2026-06-05 (+07)

📋 **Đơn Đặt trước (Pre-Order) · Bộ chọn giờ 24h**

### Added
- **Bộ chọn giờ 24h (`Time24`):** thay `<input type="time">` ở form tạo đơn & sửa đơn bằng 2 dropdown
  giờ (00–23) : phút — luôn hiển thị dạng **24:00**, không phụ thuộc locale trình duyệt (hết AM/PM).
- **Đơn ĐẶT TRƯỚC (status `pre_order`):** đơn tạo có hẹn giờ giao sẽ **KHÔNG** vào bếp ngay, mà vào mục
  **"Đặt trước"** riêng trên màn Trực đơn.
  - Sắp xếp theo giờ hẹn **gần → xa**, có đếm ngược / cảnh báo trễ.
  - Nút **"Đưa vào pha"** — chỉ khi trực đơn xác nhận, đơn mới chuyển sang **"Mới"** (cần pha) của KDS,
    tránh pha nhầm đơn đặt trước quá sớm.
  - Nhắc trực đơn 1 lần khi đơn sắp tới giờ (trước 30 phút).

### Changed
- `OrderScreen`: danh sách "Đơn đang xử lý" không còn lẫn đơn đặt trước (tách hẳn mục riêng).

---

## [1.13.0] — 2026-06-05 (+07)

📊 **Dashboard Theo ngày / Toàn chuỗi · Sửa crash Báo cáo**

### Fixed
- **Crash màn Báo cáo:** `ReportScreen` thiếu `shiftAssignments`/`currentShift` (do refactor v1.12 dùng 2 biến
  này để tra Trưởng ca theo ca) → `ReferenceError`. Đã truyền 2 prop vào ReportScreen.

### Added
- **Dashboard 2 chế độ:** nút chuyển **"Theo ngày"** (như cũ, lọc theo `viewDate`) ↔ **"Toàn chuỗi"**
  (tổng kết toàn bộ mọi ngày). Chế độ toàn chuỗi: ẩn thanh chọn ngày, hiện số ngày hoạt động + tổng doanh thu,
  và biểu đồ **"Doanh thu theo ngày"** (14 ngày gần nhất) thay cho biểu đồ theo giờ.

---

## [1.12.0] — 2026-06-05 (+07)

🗑️ **Bỏ vai trò cố định — `staff.role` → `staff.is_admin` (bool)**

### ⚠️ CẦN CHẠY MIGRATION
Vào **Supabase → SQL Editor**, chạy:
```sql
ALTER TABLE staff ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='staff' AND column_name='role') THEN
    UPDATE staff SET is_admin = (role = 'admin');
    ALTER TABLE staff DROP COLUMN role;
  END IF;
END $$;
```
(Đã có sẵn trong `supabase-schema.sql`.) FE chạy đúng **dù migration trước hay sau**: cờ `ROLE_COL_OK`/`ADMIN_COL_OK`
tự phát hiện cột — chưa drop thì vẫn ghi `role` để backward-compat, không 400.

### Changed
- **Xoá cột `role`**, thay bằng `is_admin` (bool). Object staff ở FE mang `isAdmin`; map qua `staffFromDb/staffToDb`.
- Nhận diện **Admin** qua `is_admin` (fallback legacy `role='admin'` khi chưa migrate).
- **Nhân sự (Cài đặt):** ô "Vai trò" → công tắc **"Là Admin / Thành viên"**; bảng hiển thị cột **Quyền**.
- Vai trò làm việc của thành viên tính **100% theo phân ca** (`shift_assignments`); ngoài ca ⇒ màn Nghỉ.
- Script `supabase-50-accounts.sql` + seed cập nhật sang `is_admin`.

---

## [1.11.0] — 2026-06-05 (+07)

🔀 **Role theo ca · Điểm lấy hàng · Admin chạy như Thành viên**

### ⚠️ CẦN CHẠY MIGRATION (để bật điểm lấy hàng)
Vào **Supabase → SQL Editor**, chạy:
```sql
CREATE TABLE IF NOT EXISTS pickup_locations (
  id BIGINT PRIMARY KEY, name TEXT NOT NULL, sort INT NOT NULL DEFAULT 0
);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS pickup_id BIGINT;
ALTER TABLE pickup_locations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "open_all" ON pickup_locations;
CREATE POLICY "open_all" ON pickup_locations FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE pickup_locations; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
```
(Đã có sẵn trong `supabase-schema.sql`.) Chưa chạy → tính năng điểm lấy hàng tạm ẩn, app vẫn chạy bình thường.

### Added
- **Điểm lấy hàng (`pickup_locations`):** Admin quản lý danh sách trong **Cài đặt → Cài đặt chung**.
  Khi tạo/sửa đơn có **dropdown chọn điểm lấy hàng**. Hiển thị trên card đơn, màn phân shipper,
  và nổi bật trong app Shipper (kèm địa chỉ giao). Cờ `PICKUP_DB_OK`/`ORDER_PICKUP_OK` tự phát hiện migration.
- **Admin chạy như Thành viên:** tài khoản admin mặc định vào chế độ **Admin**; bấm
  **"Xem như Thành viên"** (sidebar) để chạy app theo role được phân trong ca. Thanh nổi **"Về chế độ Admin"**
  để quay lại bất cứ lúc nào.

### Changed
- **Role tính 100% theo ca:** thành viên không còn dùng `staff.role` cố định lúc chạy — role lấy từ
  **phân ca** (`shift_assignments`). Chưa tới ca / chưa được phân ⇒ màn **Nghỉ**. `staff.role` chỉ còn để
  xác định **Admin** (giữ cột, không drop). Form Nhân sự ghi rõ "vai trò thực tế theo phân ca".

---

## [1.10.2] — 2026-06-04 (+07)

📲 **Telegram BOT_TOKEN lưu vào tài khoản Admin (sync mọi máy)**

### ⚠️ CẦN CHẠY MIGRATION (để token sync đa thiết bị)
Vào **Supabase → SQL Editor**, chạy:
```sql
ALTER TABLE staff ADD COLUMN IF NOT EXISTS tg_token TEXT;
```
(Đã có sẵn trong `supabase-schema.sql`.) Chưa chạy thì token vẫn hoạt động kiểu **localStorage từng máy** như cũ — không vỡ gì.

### Added / Changed
- **Token theo tài khoản Admin:** khi admin bấm "Lưu & Kiểm tra" ở Cài đặt → Telegram Bot,
  BOT_TOKEN được ghi vào **tất cả tài khoản admin** trên DB. Mọi máy (bất kỳ ai mở app)
  **tự nạp token** lúc khởi động → Telegram chạy toàn hệ thống, không cần cấu hình từng máy.
- Cờ `TG_DB_OK` phát hiện cột `tg_token` lúc khởi động; chưa migrate → không ghi (tránh lỗi 400).
- "Xoá token" cũng xoá khỏi tất cả tài khoản admin.
- ⚠️ **Lưu ý bảo mật:** token nằm trong bảng đọc được bằng anon key (RLS open) — chỉ dùng cho **bot nội bộ**.
  Nếu cần bảo mật token, dùng cơ chế server-side riêng (không nằm trong scope hiện tại).

---

## [1.10.1] — 2026-06-03 (+07)

🗑️ **Xác nhận khi huỷ đơn** (pop-up) + tinh chỉnh sửa đơn

### Added
- **Xác nhận huỷ đơn:** nút Huỷ ở màn Trực đơn nay mở **pop-up xác nhận** (component `ConfirmDialog`)
  hiển thị mã đơn, khách, danh sách món & tổng tiền + cảnh báo "không thể hoàn tác" trước khi huỷ.
  Tránh huỷ nhầm. (Đã verify live: mở dialog → "Không" thì đơn giữ nguyên.)

### Changed / Fixed
- **Sửa đơn:** khi đổi loại đơn **Ship → Tại chỗ**, tự **bỏ shipper đã phân** (`sid=null`) và xoá hẹn giao.
- **Sửa đơn:** khởi tạo giảm giá gọn lại (bỏ `useEffect` thừa, set thẳng dạng "đ" theo số tiền đã lưu) — hết nhấp nháy 1 frame.

### Verified (live preview)
- Trưởng ca thấy nút ✏️ Sửa; modal mở đúng cho đơn ship (khách/KPI/địa chỉ/phí ship/hẹn giao/món/giảm giá/tổng).
- 50 account demo đã chạy (KPI picker hiển thị nhân sự từ `supabase-50-accounts.sql`).

---

## [1.10.0] — 2026-06-03 (+07)

✏️ **Sửa đơn sau khi đã chốt** (pop-up) + 🛵 **Trực đơn được phân shipper** + 👥 **Script 50 account demo**

### Added
- **Sửa đơn đã chốt (pop-up):** Trưởng ca / Trực đơn / Admin có nút **✏️ Sửa** trên mỗi đơn đang xử lý.
  Mở modal pop-up cho phép sửa: khách hàng, SĐT, người nhận KPI, loại đơn (tại chỗ/ship),
  địa chỉ + phí ship, hẹn ngày/giờ giao, thêm/bớt món & số lượng, giảm giá, thanh toán, ghi chú.
  Khi lưu **tự đối soát kho** theo chênh lệch số lượng (tăng → trừ thêm kho, giảm → hoàn kho);
  giới hạn số lượng tối đa = tồn kho hiện tại + phần đã trừ cho chính đơn đó.
- **Trực đơn được phân shipper:** thêm màn **Giao hàng** vào quyền `truc_don` và cho phép trực đơn
  bấm phân công shipper (trước đây chỉ trưởng ca / admin).
- **`supabase-50-accounts.sql`:** script seed **50 tài khoản demo** (2 admin · 6 trưởng ca · 14 trực đơn ·
  14 pha chế · 14 shipper), id 101–150, PIN 1001–1050, idempotent (`ON CONFLICT DO NOTHING`).
  Tự sửa name/role/pin theo nhân sự thật khi triển khai.

### Changed
- `ROLE_PERMS.truc_don`: `["order","dashboard"]` → `["order","shipper","dashboard"]`.
- Thông báo từ chối phân shipper đổi thành "Bạn không có quyền phân công shipper".

---

## [1.9.5] — 2026-06-02 18:15 (+07)

📅 **Quản trị theo NGÀY** + ⏰ **Hẹn ngày giao + nhắc làm đơn trước giờ** + 🐞 fix UI/UX

### ⚠️ CẦN CHẠY MIGRATION (bắt buộc cho "hẹn ngày")
Vào **Supabase → SQL Editor**, chạy:
```sql
ALTER TABLE orders ADD COLUMN IF NOT EXISTS schedule_date TEXT;
```
(Đã có sẵn trong `supabase-schema.sql`.) App tự phát hiện cột: **chưa chạy migration vẫn hoạt động bình thường**, chỉ tạm tắt phần "hẹn ngày" cho tới khi chạy + reload (không gây lỗi ghi đơn).

### Added — Quản trị theo ngày
- Component **DateNav** (◀ ngày ▶ + chọn lịch + "↻ Hôm nay") ở **Tổng quan**, **Báo cáo**, **Nhân sự & KPI**.
- **Báo cáo theo ngày** (fix lỗi cũ cộng dồn toàn thời gian): doanh thu, tiền mặt/QR, top sản phẩm, log — lọc theo `created_at` của ngày đang chọn.
- **KPI nhân sự theo ngày** (trước ghi "hôm nay" nhưng đếm cả lịch sử).
- **Tổng quan theo ngày**: thẻ thống kê + biểu đồ giờ + đơn gần đây lọc theo ngày.
- Xem lại bất kỳ ngày quá khứ; tên file CSV theo ngày (`BaoCao_YYYY-MM-DD.csv`).

### Added — Hẹn ngày giao + nhắc nhở
- Trực đơn: thêm ô **chọn NGÀY giao** cạnh giờ giao (mặc định hôm nay). Hiển thị thứ + ngày ở KDS, Shipper, ping Telegram.
- **Nhắc làm đơn trước giờ giao** (mặc định 30 phút): KDS hiện badge "🔔 Làm trước HH:MM — còn N phút", tự tô vàng/đỏ (GẤP/TRỄ GIAO), kèm toast nhắc 1 lần/đơn. Đơn hẹn giờ không còn bị tính "trễ" oan theo thời điểm tạo.

### Fixed (UI/UX)
- **Giảm giá %**: kẹp 0–100, không còn ra tổng tiền âm khi gõ tay >100.
- **Telegram noti**: hiển thị đúng số tiền (trước luôn `0đ` do dùng `r.tot` không tồn tại).
- **CSV injection**: escape dấu `"` và prefix `'` cho ô bắt đầu bằng `= + - @`.
- "Phiên bản" trong Cài đặt hiển thị động theo `VERSION`.

### Migration
Idempotent — chạy lại `supabase-schema.sql` an toàn. Tối thiểu chỉ cần dòng `ALTER TABLE` ở trên.

---

## [1.9.4] — 2026-06-02 15:28 (+07)

🏷️ **Đổi tên app → BaBayBite** + 🐞 **Sửa lỗi ẩn panel phân công shipper**

### Fixed — ShipperScreen (trưởng ca/admin)
- **Lỗi hiển thị nặng:** toàn bộ panel "Phân công Shipper" bị ẩn với trưởng ca/admin.
- Nguyên nhân: `const effectiveRole` khai báo *sau* object `SCREENS` nhưng JSX trong `SCREENS`
  (`<ShipperScreen effectiveRole={effectiveRole}/>`) đọc biến này ngay khi tạo object. Babel
  hoist `const`→`var` → prop nhận `undefined` → `canAssign=false` → panel không render.
- Sửa: chuyển khai báo `effectiveRole` lên **trước** object `SCREENS`.
- Đã verify trực tiếp: đăng nhập trưởng ca → màn Giao hàng hiện đầy đủ panel + bước chọn shipper.

### Changed — Branding
- Đổi tên toàn bộ app hiển thị từ "CLB Quản Lý Bán Hàng" / "CLB BÁN HÀNG" → **BaBayBite**
  (title tab, logo sidebar, màn login, màn khách tự đặt, Help popup, tin nhắn test Telegram).
- Cài đặt → Thông tin hệ thống: ô "Phiên bản" giờ hiển thị động theo `VERSION` (trước hard-code sai "v3.1").

### Migration
Không cần — pure UI/branding, không thay schema/DB.

---

## [1.9.1] — 2026-06-02

🎯 **Rebuild flow phân shipper — 3-step: Chọn → Chốt → Ping**

### Changed — ShipperScreen (trưởng ca/admin)
- HERO panel **"Điều phối shipper"** hoàn toàn mới, thay thế HERO cũ + inline assign trong column san_sang
- Bao gồm cả đơn `pha_che` (đang pha) + `san_sang` (sẵn sàng) → trưởng ca pre-assign từ trước khi pha xong
- **Lọc shipper theo ca hoạt động** dựa trên `shift_assignments` (không còn lấy tất cả shipper static role)
- 3 trạng thái per card (state machine):
  - **A. Chưa chọn** → hiện chips shippers in-shift với load + StaffCombo gõ tên
  - **B. Đã chọn, chưa chốt** → preview shipper + 2 nút "↺ Chọn lại" / "✓ Chốt phân công"
  - **C. Đã chốt** → hiện thông tin shipper + nút **"🔔 Gửi thông báo Telegram"** (disabled nếu shipper chưa link chat) + "↻ Đổi shipper"
- Local state `pendingPick[oid]=sid` giữ pick chưa lưu (không sync DB cho đến khi chốt)
- Kanban column `san_sang`: bỏ inline assign buttons (đã refactor lên HERO), chỉ hiện status text

### Why
- 1-tap auto-assign cũ → dễ click nhầm, không có cơ hội xem lại tải shipper trước khi chốt
- 3-step minh bạch: trưởng ca thấy rõ ai được chọn, load bao nhiêu, có Telegram OK không → mới chốt
- Tách "chốt phân công" và "gửi noti" → trưởng ca có thể chốt im lặng (shipper đứng cạnh) hoặc chốt + ping (shipper xa)

### Migration
Không cần — pure UI refactor, không thay schema/DB.

---

## [1.9.0] — 2026-06-02

📋 **Bảng phân ca + Ping shipper + Hẹn giờ giao + Combobox gán nhân sự**

### Added — Board view (Bảng phân ca)
- View mặc định mới trong **Cài đặt → Lịch ca**: layout giống file Excel — **hàng = vai trò, cột = ca, ô = danh sách nhân sự**
- Mỗi ô có sẵn `StaffCombo` — gõ tên/username để tìm nhanh + thêm
- Click vào thẻ nhân sự để xoá khỏi ca
- 4 view tổng cộng: Bảng (mới, default) / Theo vai trò / Calendar / Ma trận

### Added — Hẹn giờ giao
- Cột mới `orders.schedule_at TEXT` (`HH:MM` hoặc null)
- OrderScreen: thêm input `type="time"` cho đơn ship (tùy chọn) — chip "⏰ Hẹn giao: 14:30"
- Hiển thị nổi bật trong ShipperApp active card (banner xanh), trong KDS card, và danh sách OrderScreen
- Mapper `orderFromDb/orderToDb` thêm `schA` ↔ `schedule_at`

### Changed — Shipper KHÔNG còn tự nhận đơn
- **Bỏ tab "Đơn chờ nhận"** + nút "🛵 Nhận đơn này" trong ShipperApp
- Bỏ logic `claim()` self-claim — concurrency update
- Tabs còn lại: **Đang giao** + **Lịch sử** (workflow rõ hơn)
- Empty state: "Trưởng ca sẽ phân đơn cho bạn. Khi có đơn mới, bạn sẽ nhận được thông báo trên điện thoại (Telegram)..."
- Realtime handler vẫn ping noti đơn `san_sang & sid=null` cho trưởng ca để chủ động phân

### Added — Ping shipper từ trưởng ca
- Nút **🔔 Ping** trên mỗi đơn đang giao (`da_lay`/`dang_giao`) trong ShipperScreen của trưởng ca
- Gửi DM Telegram đến chat_id của shipper được gán: "Nhắc nhở từ Trưởng ca · Đơn ĐH001 · Hẹn giao 14:30 · Vui lòng xử lý ngay!"
- Cảnh báo rõ nếu chưa cấu hình Telegram hoặc shipper chưa link chat

### Added — Combobox `StaffCombo` (component generic)
- Component mới `StaffCombo` reusable: text input tự gõ + dropdown filter theo `name` hoặc `username`
- Áp dụng cho:
  - Mỗi ô trong Board view ShiftSettings (gõ tên thêm nhân sự vào ca)
  - HERO panel "Đơn cần phân shipper" trong ShipperScreen — gõ tên shipper thay vì chỉ click avatar
- Vẫn giữ buttons quick-pick để khỏi mất UX nhanh (gợi ý ⭐ shipper rảnh nhất)

### Migration
```sql
ALTER TABLE orders ADD COLUMN IF NOT EXISTS schedule_at TEXT;
```
Hoặc chạy lại `supabase-schema.sql` (idempotent).

### Why
- **Board view**: CEO yêu cầu giao diện giống file Excel quen thuộc — role rows × shift columns, cell = list staff
- **Bỏ self-claim**: tránh xung đột "đơn ai nhận" và để trưởng ca làm điều phối viên (đúng vai trò)
- **Ping**: shipper có thể tắt tab → cần kênh push tin nhắn chủ động khi đơn gấp
- **Hẹn giờ giao**: nhiều khách đặt trước → pha chế + shipper cần biết deadline để ưu tiên
- **Combobox**: 1 ngày 30+ nhân sự, dropdown buttons dài → gõ vài ký tự nhanh hơn nhiều

---

## [1.8.0] — 2026-05-30

🔐 **Username login** + 🤖 **Telegram Bot POC**

### Added — Username login
- Cột mới `staff.username TEXT` (UNIQUE index trên `LOWER(username)`)
- LoginScreen: thay flow "chọn staff từ list" bằng **input text username + PIN numpad** — user tự gõ username, app tra DB → match PIN
- Auto remember username last-used qua localStorage (`lastUsername`)
- StaffSettings: thêm input "Tên đăng nhập" (validate: 2-32 ký tự, `[a-z0-9_.-]`, unique)
- Seed 6 nhân sự có sẵn username: `khanh, ha, minh, ngoc, tuan, linh`

### Added — Telegram Bot
- Cột mới `staff.telegram_chat_id TEXT` — chat ID Telegram của từng cá nhân
- Tab mới "Telegram Bot" trong Cài đặt:
  - Input BOT_TOKEN (lưu localStorage device, không sync) + nút "Lưu & Kiểm tra" gọi `getMe`
  - Nút **"Quét chat đã /start"** → gọi `getUpdates`, list các chat đã chat bot, dropdown gán-thẳng vào nhân viên
  - Grid hiển thị nhân viên đã liên kết với nút **Test gửi** (gửi tin chào)
  - List nhân viên chưa liên kết (chip xám)
- Hook noti vào realtime handler `orders`:
  - INSERT `cho_xac_nhan` ⇒ DM tất cả role `truc_don/truong_ca/admin` đang có chat_id
  - INSERT đơn nội bộ ⇒ DM `pha_che/truong_ca/admin`
  - UPDATE `san_sang & sid=null` (ship pool) ⇒ DM `shipper/truong_ca/admin`
  - UPDATE `sid` thay đổi ⇒ DM riêng shipper được gán
- **Leader election** để dedupe noti: client với `min(user.id)` trong onlineUsers gửi 1 lần (tránh N client cùng gửi)
- StaffSettings: thêm input "Telegram chat ID" + icon ✈ trong bảng

### Why
- Username (type): user CEO yêu cầu — dễ login khi list staff dài, không phải scroll dropdown
- Telegram Bot: shipper/pha chế không phải lúc nào cũng mở browser; web Notification API tắt khi đóng tab. Telegram lock-screen noti free, hoạt động native trên iOS/Android, không cần PWA install
- Client-side direct (không Edge Function): POC nhanh, đủ cho team < 15 người; token chỉ ở device admin/trưởng ca

### Migration
1. Chạy `supabase-schema.sql` (idempotent, sẽ ALTER TABLE thêm 2 columns)
2. Vào Cài đặt → Nhân sự → set username cho user cũ (nếu chỉ chạy migration không seed)
3. Admin/Trưởng ca: vào tab "Telegram Bot" → cấu hình BOT_TOKEN + link chat_id

### Known limits POC
- Token Telegram chỉ ở device đã cấu hình (không sync) — nếu device đó offline thì không có client nào gửi noti. Workaround: cấu hình trên 2-3 máy admin/trưởng ca
- Mỗi noti gửi N HTTP request (1/recipient) — OK cho team < 20 người; lớn hơn ⇒ migrate Edge Function batch send

---

## [1.7.0] — 2026-05-28

🎭 **Role hiển thị theo CA, không phải role mặc định**

### Changed
- **`RL.off = "Ngoài ca"`** + **`RC.off`** màu xám (#64748B / #F1F5F9) — chuẩn hoá label/color cho user ngoài ca
- **Helper mới `roleInShift(staffId, staffRole, shiftId, shiftAssignments)`** — trả role thực tế trong 1 ca cụ thể (admin luôn "admin", không có shift_assignment ⇒ "off")
- **Sidebar online chip**: user ca có màu role, user ngoài ca xám-in-nghiêng với dấu "·" — phân biệt rõ ai đang trực vs ai chỉ online
- **StaffScreen**:
  - 5-card thống kê đầu trang đếm theo `shiftAssignments` của ca hiện tại (không phải `staff.role` tĩnh)
  - Bảng KPI: cột "Vai trò" hiển thị role-trong-ca-này; ngoài ca ⇒ chip xám "Ngoài ca" (tooltip giữ role mặc định); chip 🏷 "theo ca" khi user được phân role khác mặc định
  - Leaderboard mờ dòng cho user ngoài ca
  - Header banner ghi rõ "Đếm theo {ca} ({giờ-bắt-đầu}–{giờ-kết-thúc})" hoặc "Ngoài giờ làm việc"

### Why
- Role tĩnh trong `staff.role` chỉ là role mặc định/khả năng — không phản ánh ai đang làm gì hôm nay
- Trước đây bảng nhân sự + online list show role default ⇒ misleading khi 1 trực-đơn được phân làm pha-chế trong ca tối
- Giờ UI thống nhất quanh **effective role per shift** (đã có từ v1.1 cho Sidebar/TopBar) — extend sang Staff & presence

---

## [1.6.1] — 2026-05-26

🗑 **Admin có quyền xoá vĩnh viễn đơn (mọi stage)**

### Added
- 🛡️ **`deleteOrder` helper trong App** — chỉ admin được gọi (check qua `currentUserRef.current?.role === "admin"`):
  - Confirm dialog **2 dòng** hiển thị: mã đơn, khách, tổng tiền, trạng thái + cảnh báo "KHÔNG THỂ phục hồi"
  - **Hoàn kho tự động** nếu đơn chưa kết thúc (st ∉ {huy, hoan_thanh, hoan_hang})
  - DELETE thật khỏi Supabase (qua `setOrders` diff wrapper)
- 🖥️ **Dashboard table**:
  - Admin thấy thêm cột **"Hành động"** với nút `🗑 Xoá` đỏ
  - Admin thấy **30 đơn gần nhất** (thay vì 6 cho các role khác)
  - Header hiển thị "Hiển thị X/Y đơn · Admin có quyền xoá"
- 📋 **OrderScreen active card**: thêm nút 🗑 nhỏ bên cạnh "Huỷ" cho admin

### Why
- Khác biệt giữa **"Huỷ" (st=huy, đơn vẫn tồn tại)** và **"Xoá" (delete khỏi DB)**: Huỷ giữ lịch sử cho báo cáo, Xoá dùng cho test data, đơn ma, lỗi nhập sai
- Chỉ admin (không phải trưởng ca) để giảm rủi ro mất data

---

## [1.6.0] — 2026-05-26

🎨 **Phân ca theo Role-first · Re-assign shipper · Polish ưu tiên**

### Added
- 👥 **Phân ca theo vai trò (Role-first view)** — tab mặc định mới trong Cài đặt → Lịch ca:
  - Mỗi ca là 1 card; bên trong chia 5 bucket theo role (Trưởng ca / Trực đơn / Pha chế / Shipper / Admin)
  - Mỗi bucket có chip avatar người đã phân + nút "+ Thêm"
  - Click "+ Thêm" → expand picker chip ngang, click người → instant add với role tương ứng
  - Click chip người trong bucket → confirm xoá khỏi ca
  - Ngôi sao ★ đánh dấu staff có role mặc định khớp với bucket đang chọn
  - Nút "📋 Copy từ [Ca trước]" + "🗑 Xoá hết" ở footer mỗi card
  - 3 view toggle: 👥 Theo vai trò (default) · 📅 Calendar · 📊 Ma trận
- 🔄 **Re-assign shipper bất kỳ stage** — admin/trưởng ca có thể chuyển đơn đang `da_lay`/`dang_giao` sang shipper khác:
  - Mỗi card đơn trong cột "Đã lấy"/"Đang giao" có dòng "Đổi shipper:" với chip các shipper khác
  - Click chip → confirm → đổi sid + **tự động reset status về `san_sang`** để shipper mới bắt đầu flow từ pickup (tránh lỗi shipper mới "đang giao" nhưng chưa lấy hàng)
- ⭐ **Suggest shipper rảnh nhất** trong Hero card phân công:
  - Tính load = số đơn active của mỗi shipper
  - Shipper rảnh (load=0) có border dày + dấu ⭐ góc trên
  - Hiển thị số đơn đang giao bên cạnh icon 🛵
- ⚠️ **Cảnh báo đơn khách chờ duyệt quá lâu** — trong panel "Đơn khách chờ duyệt" của OrderScreen:
  - Hiển thị "Chờ Xp" (X = phút từ lúc khách đặt)
  - Nếu > 5 phút: border đỏ, icon ⚠ nhấp nháy, màu đỏ thay vì vàng

### Changed
- ShipperScreen assign function: re-assign từ `da_lay`/`dang_giao` → reset state về `san_sang` thay vì để shipper mới kế thừa state cũ
- Default view của ShiftSettings: từ Calendar → "Theo vai trò" (rõ ràng hơn cho người mới)

---

## [1.5.1] — 2026-05-26 (hotfix)

🔧 **Hotfix: Shipper không nhận được đơn**

### Fixed
- 🐛 **Bug nghiêm trọng**: Khi pha chế "Hoàn thành pha" cho đơn ship → KDS tự đẩy thẳng sang `dang_giao` (bỏ qua bước shipper nhận). Hậu quả: pool shipper luôn rỗng vì đơn không bao giờ ở trạng thái `san_sang` đủ lâu.
- ✅ Sửa `nxSt`: đơn ship ở `san_sang` → trả về `null` (dừng), KDS không show button advance nữa
- ✅ Sửa `nxLb`: ẩn nhãn "→ Chuyển shipper" cho đơn ship ở san_sang
- ✅ Thêm chip hint trong KDS cho đơn ship đã pha xong: vàng "🛵 Đang chờ shipper nhận đơn" hoặc xanh "🛵 [Tên shipper] sẽ tới lấy"

### Flow đúng sau hotfix

```
Trực đơn tạo (st=moi)
  → KDS: tap "Bắt đầu pha" (moi→pha_che)
  → KDS: tap "Hoàn thành pha" (pha_che→san_sang)
  → Nếu tai_cho: KDS tap "Hoàn thành" (san_sang→hoan_thanh)
  → Nếu ship: KDS DỪNG. Đơn vào pool shipper
     → Shipper tab "Đơn chờ nhận": tap "Nhận đơn này" (sid được set)
     → Shipper tab "Đang giao": tap "Đã lấy hàng" (san_sang→da_lay)
     → Tap "Bắt đầu giao" (da_lay→dang_giao)
     → Tap "Đã giao thành công" (dang_giao→hoan_thanh)
```

---

## [1.5.0] — 2026-05-26

🚀 **Role-specific apps · Customer hybrid · Shift grid v2 · Self-claim shipper pool**

Tổng hợp 3 release candidate (rc1/rc2/rc3) thành release chính thức.

### Added
- 🛵 **Shipper standalone App** (Grab Driver style): full-screen, không sidebar/topbar admin. Header đen có Thoát + connection. 3 tab: **Đơn chờ nhận** / **Đang giao** / **Lịch sử**. Active order card to với tap-to-call, mở Google Maps deep-link, CTA gradient theo trạng thái
- 🆕 **Self-claim pool**: shipper tap "Nhận đơn" → `UPDATE WHERE sid IS NULL` (concurrency-safe). Trưởng ca vẫn có quyền gán thủ công
- ☕ **Pha chế standalone App**: header xanh, KitchenScreen full-screen, không sidebar
- 📋 **Trực đơn standalone App**: header cam, OrderScreen full-screen, không sidebar
- 🚨 **Hero "Đơn cần phân shipper"** ở màn Giao hàng (trưởng ca/admin): card cam pulse, quick-assign avatar chip (xanh = sẵn sàng, vàng = đang giao đơn khác)
- 🔔 **Customer hybrid duyệt 1-tap**:
  - Status mới `cho_xac_nhan` cho đơn khách tự đặt qua `?customer=1` hoặc `?qr=<bàn>`
  - Đơn vào trạng thái này **không trừ kho** (tránh lãng phí cho đơn bị từ chối)
  - OrderScreen có panel vàng "🔔 X đơn khách chờ duyệt" ở đầu danh sách
  - Tap **"✓ Duyệt · KPI về tôi"** → trừ kho + gán KPI=user hiện tại + chuyển sang `moi`
  - Tap **"✕ Từ chối"** → prompt lý do → set `huy` với `returnReason`
  - Tự động check đủ kho trước khi duyệt; thiếu → toast cảnh báo
  - Push notif cho trực đơn/trưởng ca/admin khi có đơn vào pool
  - Progress bar cho customer view có thêm bước "cho_xac_nhan"
- 📊 **Shift grid view (Ma trận) — cải tiến lớn**:
  - Click ô → cycle qua role tiếp theo (không cần mở dropdown)
  - Chuột phải → đặt nhanh role "Nghỉ"
  - Nút **📋 Copy ←** ở header mỗi cột → sao chép toàn bộ phân công từ ca trước (xoá ca hiện tại rồi paste)
  - Hint banner cam ở dưới giải thích thao tác

### Changed
- ST const: thêm status `cho_xac_nhan` (vàng amber) ở vị trí đầu chuỗi trạng thái
- App() có 3 early-return cho 3 role: shipper / pha_che / truc_don. Admin / Trưởng ca giữ shell hiện tại (sidebar + topbar + nav 7 màn)
- Notification: thêm event "đơn khách chờ duyệt" cho role truc_don/truong_ca/admin

### Notes
- Demo mô hình **Hybrid có duyệt** cho customer order — phù hợp scale CLB sinh viên
- Pha chế chưa có step-by-step checklist + quản lý nguyên liệu (giữ cho v2.0 theo yêu cầu)

---

## [1.5.0-rc3] — 2026-05-26 (preview)

🎨 **Pha chế + Trực đơn standalone apps · Assigner UI cải tiến**

### Added
- 🛠️ **RoleAppShell** — vỏ standalone tối giản (header + logout + status, không sidebar/topbar admin) dùng chung cho các role không phải admin/trưởng ca
- ☕ **Pha chế giao diện riêng** (`effectiveRole==='pha_che'`): header xanh đậm + KitchenScreen full-screen, không còn sidebar trái
- 📋 **Trực đơn giao diện riêng** (`effectiveRole==='truc_don'`): header cam đậm + OrderScreen full-screen
- 🚨 **Hero "Đơn cần phân shipper"** ở màn Giao hàng của trưởng ca/admin:
  - Card cam nổi bật ở đầu màn, badge pulse, hiển thị từng đơn `san_sang & sid IS NULL`
  - Quick-assign chip avatar: xanh = sẵn sàng, vàng = đang giao đơn khác
  - Cảnh báo đỏ nếu ca không có shipper nào (kiểm tra Lịch ca)

### Notes
- Còn cho v1.5.0 final: customer hybrid duyệt 1-tap + shift grid view

---

## [1.5.0-rc2] — 2026-05-26 (preview)

🛵 **Shipper App standalone + Self-claim pool**

### Changed
- 🏠 **Shipper giờ có app riêng full-screen** — KHÔNG còn dùng sidebar/topbar của admin. App() early-return `<ShipperApp/>` khi `effectiveRole==='shipper'`:
  - Header đen riêng có nút **Thoát**, connection status (Online / Mất kết nối)
  - Earnings bar đen sang, 3 metric (Đã giao / Hoàn hàng / Tỉ lệ %)
  - 3 tab: **Đơn chờ nhận** (pool) · **Đang giao** (active) · **Lịch sử**
  - Badge đỏ pulse khi pool có đơn mới
- 🆕 **Tab "Đơn chờ nhận" — Self-claim pool**:
  - Tự động lọc đơn `st=san_sang` và `sid IS NULL`
  - Card vàng có badge "MỚI", thông tin khách + địa chỉ + phí ship
  - Nút **"🛵 Nhận đơn này"** (xanh, full-width) — concurrency-safe (UPDATE WHERE sid IS NULL); nếu đơn đã bị shipper khác lấy → toast cảnh báo, không update state
  - Trưởng ca vẫn có quyền gán thủ công (view assigner giữ nguyên)
- 🔔 **Notification mới cho shipper**: khi có đơn vào pool, shipper online sẽ nhận thông báo "🆕 Đơn mới có thể nhận: ĐHxxx"

### Notes
- Vẫn là rc, còn 2 task cho v1.5.0 final: customer hybrid + shift grid
- Pha chế + Trực đơn vẫn dùng shell cũ (sẽ standalone trong release sau)

---

## [1.5.0-rc1] — 2026-05-26 (preview)

🛵 **Shipper UI rebuild — phong cách Grab Driver / ShopeeFood Driver**

### Changed
- 🛵 **ShipperScreen view khi `effectiveRole==='shipper'`** rebuild hoàn toàn theo focus 1 đơn/lần:
  - **Earnings bar** sticky trên cùng: avatar + tên + status "đang nhận đơn", phí ship hôm nay (highlight vàng), 3 metric chip (đã giao / hoàn hàng / tỉ lệ %)
  - **Tab switcher** "Đơn đang chạy" / "Lịch sử hôm nay" với badge số đơn
  - **Active order card** to, đầy đủ thông tin tách block:
    - Status header với icon + tiêu đề + hướng dẫn ngắn
    - Customer block với nút phone hình tròn xanh **tap-to-call** (`tel:` link)
    - Address block với icon map-pin + nút **"Mở Google Maps"** mở tab mới (`maps.google.com/?api=1&query=`)
    - Note block highlight vàng nếu có ghi chú khách
    - Items list + tổng phí ship (gradient cam) + số tiền khách phải trả
    - CTA button khổng lồ ở cuối (~50px), gradient theo trạng thái (tím→cam→xanh)
  - **Queue list** các đơn khác đang chạy: card compact, click để focus
  - **History tab**: 1 row mỗi đơn với icon trạng thái tròn, phí ship, giờ giao, lý do hoàn hàng (nếu có)
- 🔄 Sort active orders theo priority `dang_giao → da_lay → san_sang` rồi đến số đơn

### Why
- Shipper dùng điện thoại 1 tay, cần thông tin to + CTA dễ tap khi đang lái xe
- Grid view cũ dày, khó scan; giờ luôn có 1 đơn "đang focus" rõ ràng
- Tích hợp `tel:` + Maps deep-link giảm thao tác

### Notes
- ⚠️ Bản **rc1** chưa release final. Còn 2 task nữa cho v1.5.0:
  - Customer hybrid: `cho_xac_nhan` status + duyệt 1-tap ở OrderScreen
  - Shift grid view + click cycle role
- View Trưởng ca/Admin của ShipperScreen giữ nguyên (chỉ shipper view đổi)

---

## [1.4.0] — 2026-05-26

🔧 **Sửa loạt bug realtime + UX feedback từ owner**

### Added
- 🛍️ **Trang khách hàng tự đặt đơn** (`?customer=1` hoặc `?qr=<table_id>`) — không cần PIN, mobile-first
  - Menu lọc theo category với chip filter sticky
  - Floating cart bar dưới cùng với badge số món + tổng
  - Bottom sheet xác nhận đơn: tên, SĐT, loại đơn, địa chỉ + chọn zone phí ship, ghi chú
  - Sau khi đặt: màn status với progress bar 5 bước (Mới → Pha → Sẵn sàng → Đang giao → Hoàn thành), tự cập nhật realtime qua channel riêng `customer-order-<num>`
  - Lưu order vào localStorage để khách quay lại xem trạng thái
- 🟢 **Online presence trong Sidebar** — dùng Supabase Realtime Presence track ai đang login, hiển thị số người online + chip tên người gần nhất, dedupe theo `staff_id` (1 user mở nhiều tab vẫn đếm là 1)
- 🎯 **KPI combobox autocomplete** — thay `<select>` thuần bằng searchable picker với:
  - Search box (focus tự động khi mở)
  - Sort người trong ca lên trước, người ngoài ca xuống dưới
  - Chip cảnh báo đỏ "ngoài ca" khi chọn người không phân công ca hiện tại
  - Click outside để đóng dropdown

### Fixed
- 🔧 **Realtime UPDATE/DELETE thiếu `p.old` đầy đủ** — thêm `REPLICA IDENTITY FULL` cho `orders`, `products`, `staff`, `shift_assignments` trong `supabase-schema.sql`. Trước đây notify shipper khi `sid` đổi bị silent fail vì `p.old.sid` luôn null
- 🔧 **Huỷ đơn không hoàn kho** — sửa 2 chỗ `cancel()` ở OrderScreen + ShipperScreen: cộng lại stock cho từng product trong order. Có guard chống hoàn 2 lần (check `st` chưa thuộc `huy/hoan_thanh/hoan_hang`)
- 🔧 **Dashboard sub** — phân biệt rõ "X thành viên phân ca" vs "🟢 N đang online"

### Notes
- ⚠️ **Cần chạy lại `supabase-schema.sql`** trên Supabase Dashboard sau khi pull để áp `REPLICA IDENTITY FULL` (idempotent — chạy lại an toàn)
- ⚠️ Customer page hiện cho phép anon insert orders qua RLS `open_all`. Khi public thật cần thêm rate-limit (Edge Function) hoặc captcha

---

## [1.3.1] — 2026-05-17

🎨 **UI/UX overhaul tiếp theo (Nhóm C + D): KDS, Shipper, Dashboard, Login, Sidebar, TopBar + OrderScreen single-scroll**

### Changed
- 🛒 **OrderScreen restructure** — toàn bộ panel trái (form khách + sản phẩm + giỏ hàng) gộp vào **một vùng scroll duy nhất**, không còn 3 vùng overflow lồng nhau với `maxHeight:42vh` (trước đây dễ che bớt nội dung). Search/cats bar `position:sticky` ở đầu, header giỏ hàng `position:sticky`, footer "Tạo đơn" `flexShrink:0` luôn ở đáy panel
- 🛒 **Footer CTA** thêm dòng tóm tắt **"{N} món · {Tại chỗ/Ship} · Tổng {amount}"** phía trên button, button gọn hơn ("Tạo đơn ngay") để tránh trùng thông tin
- 📊 **Dashboard** stat cards có gradient accent ở góc trên-phải + icon shadow, số to (24px) + letter-spacing âm; bar chart highlight giờ hiện tại với gradient cam + shadow; status bars cao hơn (6px); table có header background xám, row hover, empty state
- 🍳 **KitchenScreen** — column header có icon + count chip màu theo status + sticky với backdrop-blur; thẻ đơn có 2 mức urgent (>10p = vàng "SẮP TRỄ", >15p = đỏ "TRỄ" + shake animation); badge thời gian có icon clock; CT button to hơn (pill); button advance dùng gradient theo cột
- 🚚 **ShipperScreen** — `ShipperOrderCard` có border-left màu theo status, layout block hơn (customer info + address có icon Tabler), payment chip; action buttons (Đã lấy/Bắt đầu giao/Hoàn thành) chuyển sang `btn-pri-grad` hoặc gradient xanh consistent
- 🔐 **LoginScreen** — background gradient 3-stop + 2 radial blobs cam (depth), card glass effect (backdrop-blur + translucent), logo 68px với gradient + sh-or, PIN dots có animation `pop` khi nhập, icon error có `ti-alert-circle`, numpad button hover state đổi sang orange tint với border
- 🧭 **Sidebar** — header có gradient nền + logo gradient với shadow cam, active nav item có pill accent bên trái + shadow + smooth hover, badge dùng gradient cam thay vì đỏ flat, logout button dùng `.btn-ghost`
- ⬆️ **TopBar** — clock chip có viền + background nhạt, connection status pill có ring glow ngoài, notification button to hơn (36px) với border màu khi active, profile chip có shadow

### Fixed
- ⚠️ **OrderScreen "che mất tính năng"** — trước đây customer info bị giới hạn 42vh có thể che phí ship/preset address khi scroll; cart panel 42vh có thể che dòng giảm giá. Giờ scroll thoáng toàn panel, button "Tạo đơn" vẫn sticky dưới cùng
- ⚠️ **KDS mobile** — 3 cột kanban trước đây bị squashed trên mobile; giờ scroll ngang với `min-width:280px` mỗi cột
- ⚠️ **OrderScreen mobile** — `.order-right` cap 46vh → 50vh để hiển thị thêm 1-2 đơn xử lý
- ⚠️ **Mobile menu button** — trước trông như link text, giờ có nền `var(--orl)` + radius rõ ràng (tap target tốt hơn)

---

## [1.3.0] — 2026-05-17

🎨 **UI/UX overhaul (Shopee-inspired): design tokens + OrderScreen polish**

### Added
- 🎨 **Design token system** — mở rộng `:root` với semantic colors (`--ok`, `--warn`, `--err`, `--info`), text scale (`--text2`, `--mut2`), radius scale (`--r-sm/md/lg/pill`), shadow scale (`--sh-sm/md/lg/or`), gradient brand (`--or-grad`), motion easing (`--ease`)
- ✨ **Hover/focus polish** — focus ring 3px orange (12% alpha) trên mọi input/select/textarea; `button:active` micro press-down
- 🎴 **Card hover lift** — class `.card-hover` cho subtle elevation khi rê chuột
- 🏷️ **Chip primitives** — class `.chip`, `.chip-or` để badge nhất quán
- 💫 **Animation library** — `shake`, `pop`, `shimmer` (skeleton); `fadeUp`/`fadeIn` upgraded với cubic-bezier
- 📐 **Text clamp utils** — `.clamp-1`, `.clamp-2` cho tên sản phẩm dài
- 🔘 **Button variants** — `.btn-pri-grad` (gradient CTA), `.btn-ghost` (secondary outline)

### Changed
- 🛒 **OrderScreen — Product card** Shopee-style: emoji to (38px) trong khung, tên 2-line clamp, giá nổi bật, stock badge góc trái, qty bubble góc phải khi đã chọn, hover lift + shadow cam khi active
- 🛒 **Cart panel header** mới với icon + count chip + nút "Xoá tất cả"; empty state có icon + hint
- 🛒 **Cart row** chuyển sang separator dashed, qty stepper to hơn (28→34px), nút xoá hover đỏ với icon `ti-trash`
- 🛒 **Search bar** có icon `ti-search` bên trái + nút clear (✕) bên phải khi có nội dung
- 🛒 **Category tabs** thêm shadow cam khi active, padding rộng hơn cho tap target mobile
- 🛒 **Footer CTA** gradient button với icon + đếm số món + tổng tiền in-line
- 📋 **Active orders panel** — border-left màu theo status, header sticky, customer info có icon, items list trong khung nền nhạt, note có background cam nhạt
- 🎨 **Bdg / TPill / StBdg** đồng bộ pill style (radius-pill, weight 700, kích thước tap-friendly)
- 🎚️ **Qty stepper** màu cam (thay vì xám), có border phân chia giữa số và nút +/−
- 🍞 **Toast** thêm border-left 4px (visual hierarchy), close button dạng pill nền translucent, shadow lớn hơn
- 🖱️ **Scrollbar** rộng hơn (8px), border trong suốt cho cảm giác "floating" — đỡ chiếm chỗ visual

### Fixed
- ⚠️ Focus state input trước đây chỉ đổi border, dễ miss → giờ có ring 3px rõ
- ⚠️ Stock badge `Còn N` ở stock thấp/cao trông giống nhau → giờ có dấu `●` + màu khác biệt
- ⚠️ Cart "xoá" trước đây dùng `✕` text bé, dễ nhầm → giờ là icon trash với hover đỏ
- ⚠️ "Loại đơn" buttons không có tap target rõ ràng → padding tăng + emoji size lớn hơn

---

## [1.2.1] — 2026-05-17

🔧 **Fix nhỏ: button "Tạo đơn" cố định đáy panel**

### Changed
- 🎯 Tách button "Tạo đơn" ra khỏi cart panel, đặt thành **footer độc lập với `flexShrink:0`** ở cuối `.order-left` — button giờ **luôn hiển thị ở đáy panel** bất kể cart đầy/rỗng, không bị ảnh hưởng bởi scroll của cart hay products
- Cart panel scrollable maxHeight giảm `45vh` → `40vh` (vì button đã tách ra ngoài)
- Button có `box-shadow` viền cam phía trên để nổi bật như sticky CTA

---

## [1.2.0] — 2026-05-17

🚚 **Shipper workflow chi tiết + Lịch ca calendar + 5 ca cố định**

### Added
- 🛵 **Shipper status flow chi tiết**: `san_sang` (chờ lấy) → `da_lay` (đã lấy hàng) → `dang_giao` → `hoan_thanh` / **`hoan_hang`** (kèm lý do)
- 📝 **ReturnReasonModal** — modal nhập lý do hoàn hàng (5 preset + custom)
- 👤 **Shipper personal view** — màn hình riêng cho shipper, chỉ thấy đơn được giao cho mình, với 4 panel: Chờ lấy / Đã lấy / Đang giao / Lịch sử
- 🔔 **Browser notification cho shipper** — khi bị Trưởng ca gán đơn (`r.sid` đổi sang chính họ)
- 📅 **ShiftSettings v2 — Calendar view** — mỗi ca là một card, hiển thị nhân sự đã gán + role, có nút "Thêm nhân sự" với picker
- 🔄 Toggle **Calendar ↔ Matrix view** trong Cài đặt → Lịch ca
- 🗓️ **5 ca cố định** mặc định: 07:30-09:30, 09:30-12:30, 12:30-14:30, 14:30-17:00, 17:00-19:00

### Changed
- 🐛 **Fix Order screen lần 2**: thêm `overflow:hidden` + `min-height:0` cho `.order-left`, customer info có scroll riêng `maxHeight:40vh`, products grid có `minHeight:140`, cart panel giảm xuống `maxHeight:45vh`. Button "Tạo đơn" giờ **luôn hiển thị** dù cart đầy
- 🔒 **Permission shipper**: chỉ `truong_ca` / `admin` được phân công shipper. Trực đơn / pha chế không thấy nút assign
- 📊 ShipperScreen với role admin/trưởng ca: 4 cột Kanban (Chờ / Đã lấy / Đang giao / Hoàn thành) + panel hoàn hàng riêng
- Status panel shipper hiển thị real workload (`da_lay` + `dang_giao` = busy)

### Database migration (cần chạy lại `supabase-schema.sql`)
- `ALTER TABLE orders ADD COLUMN IF NOT EXISTS return_reason TEXT`
- Auto reset shifts từ 3 ca cũ (`Ca sáng/trưa/chiều`) sang 5 ca mới — chỉ TRUNCATE nếu phát hiện schedule 3-ca cũ

---

## [1.1.0] — 2026-05-11

🕐 **Multi-shift role system + Push notifications**

### Added
- 🗓️ **Bảng `shifts` (plural)** — nhiều ca trong ngày (Ca sáng, Ca trưa, Ca chiều)
- 👥 **Bảng `shift_assignments`** — phân công role cho từng staff trong từng ca
- 🎯 **Effective role** — role thực tế trong ca hiện tại, **tự thay đổi theo giờ**
- 🛏️ **RestScreen** — màn hình "Đang nghỉ" cho thành viên không có ca hiện tại, kèm thông tin ca tiếp theo
- ⚙️ **Settings → Lịch ca & Phân công** — admin grid để gán role per shift per staff với UI ma trận trực quan
- 🔔 **Browser Notifications** — bell icon trên TopBar, trigger:
  - Pha chế / Trưởng ca: nhận thông báo khi có đơn mới
  - Shipper / Trưởng ca: nhận thông báo khi đơn ready ship
- 📍 Sidebar hiển thị **ca hiện tại** + badge "theo ca" khi role đã override
- 🧠 **CLAUDE.md** — project memory để future Claude Code sessions load context nhanh

### Changed
- Sidebar/TopBar dùng **effectiveRole** thay vì staff.role tĩnh
- Admin được hardcode giữ role admin xuyên ca
- Dashboard sub-text show ca hiện tại + số người trong ca thay vì ca mặc định

### Migration cần làm
- Chạy lại `supabase-schema.sql` (idempotent) → tạo 2 bảng mới + seed 3 ca + auto-gán role mặc định cho Ca sáng

---

## [1.0.0] — 2026-05-10

🎉 **Bản chính thức đầu tiên** — chuyển từ Demo sang Version 1.

### Added
- 🔐 **PIN Login** — màn đăng nhập bắt buộc khi vào app, mỗi PIN map đến một thành viên/role
- 🎯 **Role-based UI** — mỗi vai trò chỉ thấy các màn liên quan để tập trung:
  - Trưởng ca: Tổng quan + tất cả màn vận hành + Báo cáo + Nhân sự
  - Trực đơn: Trực đơn + Tổng quan
  - Pha chế: KDS
  - Shipper: Giao hàng
  - Admin: Toàn quyền + Cài đặt
- 🗂️ **Categories chỉnh sửa được** — bảng `categories` mới trong DB, tab Cài đặt → Danh mục cho phép thêm/xoá/đổi tên/đổi thứ tự
- 🚪 **Đăng xuất** — nút logout ở sidebar
- 📱 **Responsive design** — sidebar drawer trên mobile, panels tự stack, font/padding tự co
- 📋 **CHANGELOG.md** — bắt đầu đánh dấu version từ v1.0

### Changed
- 🐛 **Fix layout Order screen** — button "Tạo đơn" không còn bị che khi cart đầy (tách thành footer cố định, vùng cart có scroll riêng)
- 🚫 Loại bỏ tính năng "Switch User" — thay bằng login/logout đúng nghĩa
- 🔢 Version hiển thị trong sidebar và Login screen

### Removed
- Sidebar bỏ tag "v3.0 — Quản lý nội bộ" cũ

---

## [3.1.0] — 2026-05-10 (DEMO cuối)

### Added
- ☁️ **Tích hợp Supabase** — chuyển từ localStorage sang Postgres + realtime sync
- 📡 Realtime subscriptions trên 5 bảng (orders, products, staff, zones, shift)
- ⚡ Indicator kết nối realtime trên TopBar (xanh / vàng / đỏ)
- 📋 `supabase-schema.sql` — file SQL hoàn chỉnh để khởi tạo DB

### Changed
- Lưu trữ chuyển từ `localStorage` → Supabase Cloud (chỉ giữ PIN login ở localStorage)
- Loading screen khi đang fetch lần đầu

### Removed
- Nút "Reset dữ liệu mẫu" trong Settings (giờ data ở cloud, không thể reset client-side)

---

## [3.0.0] — 2026-05-10 (DEMO ban đầu)

### Added
- 7 màn hình hoàn chỉnh: Dashboard, Trực đơn, KDS, Giao hàng, KPI, Báo cáo, Cài đặt
- Hệ màu Shopee (`#EE4D2D`)
- Tách `by` (người tạo) và `kpi` (người nhận KPI)
- Màn Cài đặt 3 tabs: Nhân sự, Sản phẩm, Cài đặt chung
- Help popup floating button
- Recipe modal với View/Edit + import .txt + sao chép
- Export CSV với BOM UTF-8
- Mock data: 10 sản phẩm, 6 nhân viên, 5 đơn

---

## Quy ước đặt version

- **MAJOR** (1.x.x): thay đổi không tương thích ngược, refactor lớn
- **MINOR** (x.1.x): thêm tính năng tương thích ngược
- **PATCH** (x.x.1): sửa lỗi, không thêm tính năng

Khi push lên GitHub, dùng tag git để đánh dấu version:
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```
