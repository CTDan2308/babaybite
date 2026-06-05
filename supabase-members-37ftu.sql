-- ════════════════════════════════════════════════════════════════
--  BaBayBite — DANH SÁCH THÀNH VIÊN THẬT (CLB 37FTU 25-26)
--  Chạy trong Supabase → SQL Editor (sau supabase-schema.sql).
--
--  • username = 2 từ cuối viết liền không dấu (trùng thì dùng 3 từ cuối)
--  • pin      = ddmm ngày sinh · '0000' nếu thiếu ngày sinh (cần cập nhật)
--  • is_admin = TRUE cho 7 admin chỉ định + có thể thêm tài khoản chủ sở hữu
--  • Idempotent: ON CONFLICT (id) DO UPDATE — chạy lại để đồng bộ.
-- ════════════════════════════════════════════════════════════════

-- Đảm bảo có cột is_admin (nếu DB cũ chưa migrate v1.12)
ALTER TABLE staff ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='staff' AND column_name='role') THEN
    UPDATE staff SET is_admin = (role = 'admin');
    ALTER TABLE staff DROP COLUMN role;
  END IF;
END $$;

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
  ( 40, 'Tạ Quốc Phú', false, NULL, true, '2610', 'quocphu')
ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, is_admin=EXCLUDED.is_admin, active=EXCLUDED.active,
  pin=EXCLUDED.pin, username=EXCLUDED.username;

-- Tài khoản chủ sở hữu (giữ quyền đăng nhập) — đổi tên/pin theo ý bạn:
INSERT INTO staff (id, name, is_admin, checkin, active, pin, username) VALUES
  (101, 'Lê Văn Trí', true, NULL, true, '1001', 'tri')
ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, is_admin=EXCLUDED.is_admin,
  active=EXCLUDED.active, pin=EXCLUDED.pin, username=EXCLUDED.username;
