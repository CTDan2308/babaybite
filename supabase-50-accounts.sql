-- ════════════════════════════════════════════════════════════════
--  BaBayBite — SCRIPT 50 ACCOUNT DEMO
--  Chạy trong Supabase → SQL Editor (sau khi đã chạy supabase-schema.sql)
--
--  • id:        101 → 150 (tách khỏi seed mặc định 1–6, không đụng nhau)
--  • pin:       1001 → 1050 (4 số, duy nhất) — ĐỔI LẠI trước khi dùng thật!
--  • is_admin:  v1.12 — vai trò làm việc lấy theo PHÂN CA (shift_assignments),
--               cột này CHỈ đánh dấu Admin (toàn quyền). 2 admin = id 101, 102.
--  • Idempotent: ON CONFLICT (id) DO NOTHING — chạy lại an toàn, không nhân đôi.
--
--  👉 Sau khi đủ 50, bạn tự sửa name/is_admin/pin/active theo nhân sự thật.
--     Phân vai trò từng ca trong app: Cài đặt → Lịch ca & Phân công.
-- ════════════════════════════════════════════════════════════════

INSERT INTO staff (id, name, is_admin, checkin, active, pin, username) VALUES
  -- ── ADMIN (2) ─────────────────────────────────────────────
  (101,'Lê Văn Trí',     true,  NULL, true, '1001', 'tri'),
  (102,'Admin Dự Phòng', true,  NULL, true, '1002', 'admin2'),
  -- ── THÀNH VIÊN (48) — vai trò theo phân ca ────────────────
  (103,'Nguyễn Minh Anh',false, NULL, true, '1003', 'minhanh'),
  (104,'Trần Quốc Bảo',  false, NULL, true, '1004', 'quocbao'),
  (105,'Phạm Thu Cúc',   false, NULL, true, '1005', 'thucuc'),
  (106,'Hoàng Đức Duy',  false, NULL, true, '1006', 'ducduy'),
  (107,'Vũ Gia Hân',     false, NULL, true, '1007', 'giahan'),
  (108,'Đặng Khánh Huy', false, NULL, true, '1008', 'khanhhuy'),
  (109,'Bùi Lan Anh',    false, NULL, true, '1009', 'lananh'),
  (110,'Đỗ Mai Chi',     false, NULL, true, '1010', 'maichi'),
  (111,'Ngô Hải Đăng',   false, NULL, true, '1011', 'haidang'),
  (112,'Lý Thùy Dung',   false, NULL, true, '1012', 'thuydung'),
  (113,'Mai Tuấn Kiệt',  false, NULL, true, '1013', 'tuankiet'),
  (114,'Phan Ngọc Linh', false, NULL, true, '1014', 'ngoclinh'),
  (115,'Trịnh Bảo Long', false, NULL, true, '1015', 'baolong'),
  (116,'Dương Mỹ Linh',  false, NULL, true, '1016', 'mylinh'),
  (117,'Cao Nhật Nam',   false, NULL, true, '1017', 'nhatnam'),
  (118,'Hồ Yến Nhi',     false, NULL, true, '1018', 'yennhi'),
  (119,'Đinh Hoàng Phúc',false, NULL, true, '1019', 'hoangphuc'),
  (120,'Tô Thanh Quân',  false, NULL, true, '1020', 'thanhquan'),
  (121,'Lương Bích Trâm',false, NULL, true, '1021', 'bichtram'),
  (122,'Võ Anh Thư',     false, NULL, true, '1022', 'anhthu'),
  (123,'Nguyễn Đức An',  false, NULL, true, '1023', 'ducan'),
  (124,'Trần Khả Ái',    false, NULL, true, '1024', 'khaai'),
  (125,'Lê Gia Bảo',     false, NULL, true, '1025', 'giabao'),
  (126,'Phạm Đăng Khoa', false, NULL, true, '1026', 'dangkhoa'),
  (127,'Hoàng Tú Linh',  false, NULL, true, '1027', 'tulinh'),
  (128,'Vũ Minh Châu',   false, NULL, true, '1028', 'minhchau'),
  (129,'Đặng Quỳnh Như', false, NULL, true, '1029', 'quynhnhu'),
  (130,'Bùi Hữu Phước',  false, NULL, true, '1030', 'huuphuoc'),
  (131,'Đỗ Thảo Quyên',  false, NULL, true, '1031', 'thaoquyen'),
  (132,'Ngô Minh Sơn',   false, NULL, true, '1032', 'minhson'),
  (133,'Lý Phương Thảo', false, NULL, true, '1033', 'phuongthao'),
  (134,'Mai Đức Thịnh',  false, NULL, true, '1034', 'ducthinh'),
  (135,'Phan Cẩm Tú',    false, NULL, true, '1035', 'camtu'),
  (136,'Trịnh Khánh Vy', false, NULL, true, '1036', 'khanhvy'),
  (137,'Dương Bá Đạt',   false, NULL, true, '1037', 'badat'),
  (138,'Cao Văn Hậu',    false, NULL, true, '1038', 'vanhau'),
  (139,'Hồ Quang Huy',   false, NULL, true, '1039', 'quanghuy'),
  (140,'Đinh Trọng Khang',false,NULL, true, '1040', 'trongkhang'),
  (141,'Tô Đăng Lâm',    false, NULL, true, '1041', 'danglam'),
  (142,'Lương Thành Long',false,NULL, true, '1042', 'thanhlong'),
  (143,'Võ Hoàng Nam',   false, NULL, true, '1043', 'hoangnam'),
  (144,'Nguyễn Tấn Phát',false, NULL, true, '1044', 'tanphat'),
  (145,'Trần Hồng Quân', false, NULL, true, '1045', 'hongquan'),
  (146,'Lê Minh Sang',   false, NULL, true, '1046', 'minhsang'),
  (147,'Phạm Văn Tài',   false, NULL, true, '1047', 'vantai'),
  (148,'Hoàng Anh Tuấn', false, NULL, true, '1048', 'anhtuan'),
  (149,'Vũ Quốc Việt',   false, NULL, true, '1049', 'quocviet'),
  (150,'Đặng Hải Yến',   false, NULL, true, '1050', 'haiyen')
ON CONFLICT (id) DO NOTHING;

-- ── Kiểm tra nhanh ────────────────────────────────────────────────
-- SELECT is_admin, COUNT(*) FROM staff GROUP BY is_admin;
