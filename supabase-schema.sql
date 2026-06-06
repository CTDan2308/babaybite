-- ═══════════════════════════════════════════════════════════════
-- BaBayBite — SUPABASE SCHEMA (FILE SQL DUY NHẤT)
-- ═══════════════════════════════════════════════════════════════
-- Gộp toàn bộ: tables + RLS + realtime + migrations + seed data
-- (sản phẩm, zones, ca, danh mục) + DANH SÁCH THÀNH VIÊN THẬT CLB 37FTU.
--
-- Cách dùng: Supabase Dashboard → SQL Editor → paste TOÀN BỘ file này → Run.
-- Idempotent — chạy lại nhiều lần an toàn (seed chỉ nạp khi bảng trống,
-- KHÔNG ghi đè dữ liệu/sửa đổi đã có trong app).
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════
-- 1. TABLES
-- ═══════════════════════════════════════

CREATE TABLE IF NOT EXISTS products (
  id         BIGINT PRIMARY KEY,
  name       TEXT NOT NULL,
  cat        TEXT NOT NULL CHECK (cat IN ('pha_che','san_co','kho')),
  price      INT  NOT NULL DEFAULT 0,
  stock      INT  NOT NULL DEFAULT 0,
  on_menu    BOOLEAN NOT NULL DEFAULT TRUE,
  emoji      TEXT,
  recipe     JSONB NOT NULL DEFAULT '{"serves":1,"prep":"3 phút","ing":[],"steps":[]}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS staff (
  id         BIGINT PRIMARY KEY,
  name       TEXT NOT NULL,
  is_admin   BOOLEAN NOT NULL DEFAULT FALSE,   -- v1.12: thay role cố định; vai trò làm việc lấy theo phân ca
  checkin    TEXT,
  active     BOOLEAN NOT NULL DEFAULT TRUE,
  pin        TEXT,
  username   TEXT,
  telegram_chat_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- v1.8: thêm column nếu DB cũ
ALTER TABLE staff ADD COLUMN IF NOT EXISTS username TEXT;
ALTER TABLE staff ADD COLUMN IF NOT EXISTS telegram_chat_id TEXT;
-- Big Update: BOT_TOKEN Telegram lưu ở các tài khoản admin → app tự nạp cho mọi máy.
-- ⚠ Bảo mật: token đọc được bằng anon key (RLS open) — chỉ dùng cho bot nội bộ.
ALTER TABLE staff ADD COLUMN IF NOT EXISTS tg_token TEXT;

-- v1.12: BỎ VAI TRÒ CỐ ĐỊNH — thay staff.role bằng staff.is_admin (bool).
-- Vai trò làm việc của thành viên tính 100% theo phân ca (shift_assignments).
ALTER TABLE staff ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='staff' AND column_name='role') THEN
    UPDATE staff SET is_admin = (role = 'admin');   -- chuyển admin cũ sang cờ mới
    ALTER TABLE staff DROP COLUMN role;             -- drop hẳn cột role
  END IF;
END $$;
CREATE UNIQUE INDEX IF NOT EXISTS staff_username_uniq ON staff(LOWER(username)) WHERE username IS NOT NULL AND username <> '';

CREATE TABLE IF NOT EXISTS orders (
  num        BIGINT PRIMARY KEY,
  t          TEXT,
  cus        TEXT,
  ph         TEXT,
  type       TEXT NOT NULL CHECK (type IN ('tai_cho','ship')),
  adr        TEXT,
  items      JSONB NOT NULL DEFAULT '[]'::jsonb,
  st         TEXT NOT NULL DEFAULT 'moi',
  pay        TEXT NOT NULL DEFAULT 'cash',
  d_fee      INT NOT NULL DEFAULT 0,
  disc       INT NOT NULL DEFAULT 0,
  d_t        TEXT NOT NULL DEFAULT 'fixed',
  by_id      BIGINT,
  kpi_id     BIGINT,
  sid        BIGINT,
  note       TEXT,
  return_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
-- v1.2 migration: thêm cột return_reason nếu DB cũ chưa có
ALTER TABLE orders ADD COLUMN IF NOT EXISTS return_reason TEXT;

-- v1.9: hẹn giờ giao (HH:MM text — null = giao ngay)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS schedule_at TEXT;

-- v1.9.5: hẹn NGÀY giao (YYYY-MM-DD text — null = hôm nay). Dùng kèm schedule_at để nhắc làm đơn trước giờ giao.
ALTER TABLE orders ADD COLUMN IF NOT EXISTS schedule_date TEXT;

-- v1.11: điểm lấy hàng của đơn (FK pickup_locations.id — null = không chọn)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS pickup_id BIGINT;

CREATE TABLE IF NOT EXISTS zones (
  id         BIGINT PRIMARY KEY,
  lb         TEXT NOT NULL,
  fee        INT NOT NULL DEFAULT 0,
  sort       INT NOT NULL DEFAULT 0
);

-- v1.11: điểm lấy hàng (shipper đến lấy). Admin quản lý trong Cài đặt → Cài đặt chung.
CREATE TABLE IF NOT EXISTS pickup_locations (
  id         BIGINT PRIMARY KEY,
  name       TEXT NOT NULL,
  sort       INT NOT NULL DEFAULT 0
);

-- v1.15: cấu hình app (1 dòng id=1) — tài khoản VietQR nhận tiền + thưởng shipper
CREATE TABLE IF NOT EXISTS app_config (
  id         INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  bank       TEXT DEFAULT '',     -- mã ngân hàng VietQR (VD: VCB, TCB, MB...)
  acc        TEXT DEFAULT '',     -- số tài khoản nhận tiền
  name       TEXT DEFAULT '',     -- tên chủ tài khoản (IN HOA không dấu)
  ship_bonus INT  DEFAULT 0,      -- thưởng shipper / đơn giao thành công (đ)
  updated_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO app_config (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

-- Singleton "shift" (legacy, giữ để backward compat — không dùng nữa)
CREATE TABLE IF NOT EXISTS shift (
  id         INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  name       TEXT,
  start_at   TEXT,
  end_at     TEXT
);

-- Multi-shift v1.1: nhiều ca trong ngày
CREATE TABLE IF NOT EXISTS shifts (
  id         SMALLINT PRIMARY KEY,
  name       TEXT NOT NULL,
  start_at   TEXT NOT NULL,
  end_at     TEXT NOT NULL,
  sort       SMALLINT NOT NULL DEFAULT 0
);

-- Phân công role cho từng staff trong từng ca, THEO NGÀY (v1.20)
-- Khóa chính (day, shift_id, staff_id): mỗi ngày phân công riêng biệt.
CREATE TABLE IF NOT EXISTS shift_assignments (
  day        DATE     NOT NULL DEFAULT CURRENT_DATE,
  shift_id   SMALLINT NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
  staff_id   BIGINT   NOT NULL REFERENCES staff(id)  ON DELETE CASCADE,
  role       TEXT     NOT NULL,
  PRIMARY KEY (day, shift_id, staff_id)
);

-- ── MIGRATION v1.20 (idempotent): bảng cũ chỉ có (shift_id, staff_id) → thêm cột 'day' ──
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name='shift_assignments' AND column_name='day') THEN
    ALTER TABLE shift_assignments ADD COLUMN day DATE NOT NULL DEFAULT CURRENT_DATE;
    -- đổi khóa chính sang (day, shift_id, staff_id)
    ALTER TABLE shift_assignments DROP CONSTRAINT IF EXISTS shift_assignments_pkey;
    ALTER TABLE shift_assignments ADD PRIMARY KEY (day, shift_id, staff_id);
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS categories (
  key        TEXT PRIMARY KEY,
  label      TEXT NOT NULL,
  sort       INT NOT NULL DEFAULT 0
);

-- ═══════════════════════════════════════
-- 2. ROW LEVEL SECURITY (cho phép anon đọc/ghi - phù hợp demo nội bộ)
-- ═══════════════════════════════════════

ALTER TABLE products          ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff             ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders            ENABLE ROW LEVEL SECURITY;
ALTER TABLE zones             ENABLE ROW LEVEL SECURITY;
ALTER TABLE shift             ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories        ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts            ENABLE ROW LEVEL SECURITY;
ALTER TABLE shift_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pickup_locations  ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config        ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "open_all" ON products;
DROP POLICY IF EXISTS "open_all" ON staff;
DROP POLICY IF EXISTS "open_all" ON orders;
DROP POLICY IF EXISTS "open_all" ON zones;
DROP POLICY IF EXISTS "open_all" ON shift;
DROP POLICY IF EXISTS "open_all" ON categories;
DROP POLICY IF EXISTS "open_all" ON shifts;
DROP POLICY IF EXISTS "open_all" ON shift_assignments;
DROP POLICY IF EXISTS "open_all" ON pickup_locations;
DROP POLICY IF EXISTS "open_all" ON app_config;

CREATE POLICY "open_all" ON products          FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON staff             FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON orders            FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON zones             FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON shift             FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON categories        FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON shifts            FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON shift_assignments FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON pickup_locations  FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON app_config        FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- ═══════════════════════════════════════
-- 3. REALTIME (cho phép subscribe thay đổi)
-- ═══════════════════════════════════════

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE products;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE staff;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE orders;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE zones;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE shift;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE categories;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE shifts;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE shift_assignments;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE pickup_locations;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- v1.4: REPLICA IDENTITY FULL — cần để realtime UPDATE/DELETE gửi đầy đủ row cũ.
-- Code FE dùng p.old.st / p.old.sid để quyết định khi nào push notification cho shipper.
-- Không có dòng này: p.old chỉ chứa PK → logic notify shipper khi sid đổi sẽ silent fail.
ALTER TABLE orders            REPLICA IDENTITY FULL;
ALTER TABLE products          REPLICA IDENTITY FULL;
ALTER TABLE staff             REPLICA IDENTITY FULL;
ALTER TABLE shift_assignments REPLICA IDENTITY FULL;

-- ═══════════════════════════════════════
-- 4. SEED DATA (chỉ nạp lần đầu, tránh trùng)
-- ═══════════════════════════════════════

-- Thành viên thật CLB 37FTU 25-26 (chỉ nạp khi staff trống — re-run an toàn, không ghi đè sửa đổi trong app).
--   • username = 2 từ cuối viết liền không dấu (trùng → 3 từ cuối)
--   • pin = ddmm ngày sinh · '0000' nếu thiếu ngày sinh (⚠ cần cập nhật)
--   • is_admin = TRUE cho 7 admin chỉ định + tài khoản chủ sở hữu (id 101)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM staff) THEN
    INSERT INTO staff (id, name, is_admin, checkin, active, pin, username) VALUES
      -- ── Truyền thông ──
      (  1, 'Phạm Quang Chính', true , NULL, true, '2409', 'quangchinh'),
      (  2, 'Trần Bảo Châu', false, NULL, true, '1104', 'baochau'),
      (  3, 'Nguyễn Thị Quỳnh Trang', false, NULL, true, '0000', 'quynhtrang'),  -- ⚠ thiếu ngày sinh
      (  4, 'Trần Huyền Trang', false, NULL, true, '2211', 'huyentrang'),
      (  5, 'Trần Quỳnh Anh', false, NULL, true, '1810', 'quynhanh'),
      (  6, 'Nguyễn Thị Chung', false, NULL, true, '0601', 'thichung'),
      (  7, 'Thái Thị Mỹ Tâm', false, NULL, true, '1105', 'mytam'),
      (  8, 'Phan Quỳnh Mai', false, NULL, true, '1301', 'quynhmai'),
      (  9, 'Lê Quỳnh Chi', false, NULL, true, '2010', 'quynhchi'),
      ( 10, 'Đinh Hà Vy', false, NULL, true, '2408', 'havy'),
      ( 11, 'Nguyễn Lâm Huy', false, NULL, true, '0502', 'lamhuy'),
      ( 12, 'Nguyễn Thị Châu Anh', false, NULL, true, '1007', 'chauanh'),
      ( 13, 'Hồ Khánh Huyền', false, NULL, true, '3007', 'khanhhuyen'),
      -- ── Tổ chức ──
      ( 14, 'Trần Bùi Mai Uyên', false, NULL, true, '3107', 'maiuyen'),
      ( 15, 'Lê Trần Hồng Thắm', false, NULL, true, '2201', 'hongtham'),
      ( 16, 'Nguyễn Sáng', true , NULL, true, '1107', 'nguyensang'),
      ( 17, 'Nguyễn Phan Văn Trường', false, NULL, true, '0000', 'vantruong'),  -- ⚠ thiếu ngày sinh
      ( 18, 'Cao Thị Thanh Huyền', false, NULL, true, '0901', 'thanhhuyen'),
      ( 19, 'Nguyễn Mạnh Hiển', true , NULL, true, '0808', 'manhhien'),
      ( 20, 'Nguyễn Thị Ngọc Trâm', false, NULL, true, '2812', 'ngoctram'),
      ( 21, 'Lang Thị Thùy Dương', true , NULL, true, '2811', 'thuyduong'),
      ( 22, 'Trần Thị Minh', false, NULL, true, '0611', 'thiminh'),
      ( 23, 'Trần Thị Cẩm', false, NULL, true, '1201', 'thicam'),
      ( 24, 'Hoàng Minh Khang', false, NULL, true, '2310', 'minhkhang'),
      ( 25, 'Hồ Thị Tuyết Nhi', false, NULL, true, '1511', 'tuyetnhi'),
      ( 26, 'Nguyễn Thị Huyền Trang', false, NULL, true, '2911', 'thihuyentrang'),
      ( 27, 'Phạm Trà My', false, NULL, true, '0602', 'tramy'),
      ( 28, 'Hoàng Tuấn Anh', false, NULL, true, '0703', 'tuananh'),
      ( 29, 'Nguyễn Kim Sơn', false, NULL, true, '1710', 'kimson'),
      -- ── Đối ngoại ──
      ( 30, 'Trịnh Thị Lan Anh', false, NULL, true, '0908', 'lananh'),
      ( 31, 'Nguyễn Trọng Hiệp', false, NULL, true, '1212', 'tronghiep'),
      ( 32, 'Hà Lê Quỳnh Anh', true , NULL, true, '1310', 'lequynhanh'),
      ( 33, 'Lâm Mai Vi', false, NULL, true, '0601', 'maivi'),
      ( 34, 'Trần Thị Thuỳ Linh', false, NULL, true, '0508', 'thuylinh'),
      ( 35, 'Trương Thị Ánh Trăng', false, NULL, true, '0804', 'anhtrang'),
      ( 36, 'Nguyễn Thị Diệu Linh', true , NULL, true, '1612', 'dieulinh'),
      ( 37, 'Nguyễn Vân Thư', false, NULL, true, '1810', 'vanthu'),
      ( 38, 'Mai Ánh Minh', false, NULL, true, '2712', 'anhminh'),
      ( 39, 'Nguyễn Lê Dạ Thảo', true , NULL, true, '2412', 'dathao'),
      ( 40, 'Tạ Quốc Phú', false, NULL, true, '2610', 'quocphu'),
      -- ── Chủ sở hữu (giữ quyền đăng nhập) — đổi tên/pin theo ý bạn ──
      (101, 'Lê Văn Trí', true , NULL, true, '1001', 'tri');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM products) THEN
    INSERT INTO products (id,name,cat,price,stock,on_menu,emoji,recipe) VALUES
    (1,'Cà phê sữa đá','pha_che',20000,45,true,'☕',
     '{"serves":1,"prep":"3 phút","ing":["30ml espresso","200ml sữa tươi","Đá viên vừa đủ","10g đường cát"],"steps":["Pha 30ml espresso double shot","Cho đá viên vào ly 300ml","Rót 200ml sữa tươi lên đá","Đổ espresso lên mặt","Khuấy nhẹ"]}'::jsonb),
    (2,'Cà phê đen','pha_che',15000,60,true,'☕',
     '{"serves":1,"prep":"2 phút","ing":["40ml espresso","120ml nước nóng 80°C","Đá viên (tùy chọn)"],"steps":["Pha 40ml espresso","Pha loãng với nước nóng","Cho đá nếu uống lạnh"]}'::jsonb),
    (3,'Trà sữa trân châu','pha_che',25000,30,true,'🧋',
     '{"serves":1,"prep":"5 phút","ing":["300ml trà oolong","100ml sữa đặc","Trân châu 50g","Đá viên","20g đường"],"steps":["Pha trà oolong đặc để nguội","Nấu trân châu chín mềm","Cho trân châu vào ly + đá","Rót trà + sữa đặc","Lắc đều"]}'::jsonb),
    (4,'Matcha latte','pha_che',30000,25,true,'🍵',
     '{"serves":1,"prep":"4 phút","ing":["5g bột matcha Nhật","30ml nước nóng 80°C","200ml sữa tươi","15g đường","Đá viên"],"steps":["Hòa matcha với nước 80°C","Đánh bọt sữa tươi","Cho đá vào ly","Rót sữa vào trước","Thêm matcha lên trên"]}'::jsonb),
    (5,'Nước ép cam','pha_che',25000,0,false,'🍊',
     '{"serves":1,"prep":"3 phút","ing":["3 quả cam Sành","20g đường","Muối 1 nhúm"],"steps":["Ép 3 quả cam","Lọc qua rây","Thêm đường + muối","Cho đá vào ly"]}'::jsonb),
    (6,'Smoothie dâu','pha_che',35000,15,true,'🍓',
     '{"serves":1,"prep":"4 phút","ing":["150g dâu tây","100ml sữa tươi","2 tbsp mật ong","100g đá viên"],"steps":["Rửa sạch bỏ cuống dâu","Cho tất cả vào máy xay","Xay nhuyễn 30-40 giây","Rót ra ly"]}'::jsonb),
    (7,'Bánh mì pate','san_co',15000,20,true,'🥖',
     '{"serves":1,"prep":"2 phút","ing":["1 ổ bánh mì giòn","Pate gan heo","Dưa leo","Hành lá","Tương ớt","Mayonnaise"],"steps":["Nướng bánh mì giòn","Phết pate + mayonnaise","Xếp dưa leo và hành","Thêm tương ớt"]}'::jsonb),
    (8,'Snack phô mai','san_co',5000,100,true,'🧀',
     '{"serves":1,"prep":"0 phút","ing":["1 gói snack phô mai 30g"],"steps":["Mở gói và phục vụ"]}'::jsonb),
    (9,'Bánh tráng trộn','kho',20000,12,true,'🍜',
     '{"serves":1,"prep":"5 phút","ing":["Bánh tráng 3 tờ","Sa tế","Tôm khô 10g","Đậu phộng 15g","Hành phi","Rau răm","Muối me 5g"],"steps":["Xé bánh tráng","Trộn sa tế + muối me","Thêm tôm khô + đậu phộng","Thêm hành phi + rau răm","Trộn đều"]}'::jsonb),
    (10,'Khoai tây chiên','kho',18000,8,true,'🍟',
     '{"serves":1,"prep":"10 phút","ing":["Khoai tây 200g","Dầu chiên 500ml","Muối + tiêu","Sốt chấm"],"steps":["Thái khoai sợi","Ngâm nước muối 10 phút","Chiên 150°C 5 phút","Chiên 180°C 3 phút","Thêm muối tiêu"]}'::jsonb);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM zones) THEN
    INSERT INTO zones (id,lb,fee,sort) VALUES
      (1,'< 500m',   5000, 0),
      (2,'500m–1km', 8000, 1),
      (3,'> 1km',   12000, 2);
  END IF;
END $$;

INSERT INTO shift (id,name,start_at,end_at) VALUES (1,'Ca sáng','07:45','12:00')
ON CONFLICT (id) DO NOTHING;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM categories) THEN
    INSERT INTO categories (key,label,sort) VALUES
      ('pha_che','☕ Đồ pha chế', 0),
      ('san_co', '📦 Đồ sẵn có', 1),
      ('kho',    '⚡ Dùng ngay', 2);
  END IF;
END $$;

-- v1.2: 5 ca trong ngày (migration tự dọn lịch 3-ca cũ nếu phát hiện)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM shifts WHERE id IN (1,2,3) AND name IN ('Ca sáng','Ca trưa','Ca chiều')) THEN
    TRUNCATE shifts CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM shifts) THEN
    INSERT INTO shifts (id,name,start_at,end_at,sort) VALUES
      (1,'Ca 1','07:30','09:30',0),
      (2,'Ca 2','09:30','12:30',1),
      (3,'Ca 3','12:30','14:30',2),
      (4,'Ca 4','14:30','17:00',3),
      (5,'Ca 5','17:00','19:00',4);
  END IF;
END $$;

-- Seed assignments: gán mọi thành viên đang hoạt động vào Ca 1 với vai trò 'truc_don'
-- (vai trò theo ca — admin chỉnh lại trong app: Cài đặt → Lịch ca & Phân công).
-- v1.12: staff.role đã bị bỏ → KHÔNG đọc cột role nữa, dùng giá trị mặc định.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM shift_assignments) THEN
    INSERT INTO shift_assignments (day, shift_id, staff_id, role)
    SELECT CURRENT_DATE, 1, id, 'truc_don' FROM staff WHERE active = true;
  END IF;
END $$;
