-- ════════════════════════════════════════════════════════════════
--  BaBayBite — SCRIPT 50 ACCOUNT DEMO
--  Chạy trong Supabase → SQL Editor (sau khi đã chạy supabase-schema.sql)
--
--  • id:        101 → 150 (tách khỏi seed mặc định 1–6, không đụng nhau)
--  • pin:       1001 → 1050 (4 số, duy nhất) — ĐỔI LẠI trước khi dùng thật!
--  • role:      2 admin · 6 trưởng ca · 14 trực đơn · 14 pha chế · 14 shipper
--  • Idempotent: ON CONFLICT (id) DO NOTHING — chạy lại an toàn, không nhân đôi.
--
--  👉 Sau khi đủ 50, bạn tự sửa name/role/pin/active theo nhân sự thật.
--     Mỗi dòng 1 người: (id, name, role, checkin, active, pin, username)
-- ════════════════════════════════════════════════════════════════

INSERT INTO staff (id, name, role, checkin, active, pin, username) VALUES
  -- ── ADMIN (2) ─────────────────────────────────────────────
  (101,'Lê Văn Trí',     'admin',     NULL, true, '1001', 'tri'),
  (102,'Admin Dự Phòng', 'admin',     NULL, true, '1002', 'admin2'),
  -- ── TRƯỞNG CA (6) ─────────────────────────────────────────
  (103,'Nguyễn Minh Anh','truong_ca', NULL, true, '1003', 'minhanh'),
  (104,'Trần Quốc Bảo',  'truong_ca', NULL, true, '1004', 'quocbao'),
  (105,'Phạm Thu Cúc',   'truong_ca', NULL, true, '1005', 'thucuc'),
  (106,'Hoàng Đức Duy',  'truong_ca', NULL, true, '1006', 'ducduy'),
  (107,'Vũ Gia Hân',     'truong_ca', NULL, true, '1007', 'giahan'),
  (108,'Đặng Khánh Huy', 'truong_ca', NULL, true, '1008', 'khanhhuy'),
  -- ── TRỰC ĐƠN (14) ─────────────────────────────────────────
  (109,'Bùi Lan Anh',    'truc_don',  NULL, true, '1009', 'lananh'),
  (110,'Đỗ Mai Chi',     'truc_don',  NULL, true, '1010', 'maichi'),
  (111,'Ngô Hải Đăng',   'truc_don',  NULL, true, '1011', 'haidang'),
  (112,'Lý Thùy Dung',   'truc_don',  NULL, true, '1012', 'thuydung'),
  (113,'Mai Tuấn Kiệt',  'truc_don',  NULL, true, '1013', 'tuankiet'),
  (114,'Phan Ngọc Linh', 'truc_don',  NULL, true, '1014', 'ngoclinh'),
  (115,'Trịnh Bảo Long', 'truc_don',  NULL, true, '1015', 'baolong'),
  (116,'Dương Mỹ Linh',  'truc_don',  NULL, true, '1016', 'mylinh'),
  (117,'Cao Nhật Nam',   'truc_don',  NULL, true, '1017', 'nhatnam'),
  (118,'Hồ Yến Nhi',     'truc_don',  NULL, true, '1018', 'yennhi'),
  (119,'Đinh Hoàng Phúc','truc_don',  NULL, true, '1019', 'hoangphuc'),
  (120,'Tô Thanh Quân',  'truc_don',  NULL, true, '1020', 'thanhquan'),
  (121,'Lương Bích Trâm','truc_don',  NULL, true, '1021', 'bichtram'),
  (122,'Võ Anh Thư',     'truc_don',  NULL, true, '1022', 'anhthu'),
  -- ── PHA CHẾ (14) ──────────────────────────────────────────
  (123,'Nguyễn Đức An',  'pha_che',   NULL, true, '1023', 'ducan'),
  (124,'Trần Khả Ái',    'pha_che',   NULL, true, '1024', 'khaai'),
  (125,'Lê Gia Bảo',     'pha_che',   NULL, true, '1025', 'giabao'),
  (126,'Phạm Đăng Khoa', 'pha_che',   NULL, true, '1026', 'dangkhoa'),
  (127,'Hoàng Tú Linh',  'pha_che',   NULL, true, '1027', 'tulinh'),
  (128,'Vũ Minh Châu',   'pha_che',   NULL, true, '1028', 'minhchau'),
  (129,'Đặng Quỳnh Như', 'pha_che',   NULL, true, '1029', 'quynhnhu'),
  (130,'Bùi Hữu Phước',  'pha_che',   NULL, true, '1030', 'huuphuoc'),
  (131,'Đỗ Thảo Quyên',  'pha_che',   NULL, true, '1031', 'thaoquyen'),
  (132,'Ngô Minh Sơn',   'pha_che',   NULL, true, '1032', 'minhson'),
  (133,'Lý Phương Thảo', 'pha_che',   NULL, true, '1033', 'phuongthao'),
  (134,'Mai Đức Thịnh',  'pha_che',   NULL, true, '1034', 'ducthinh'),
  (135,'Phan Cẩm Tú',    'pha_che',   NULL, true, '1035', 'camtu'),
  (136,'Trịnh Khánh Vy', 'pha_che',   NULL, true, '1036', 'khanhvy'),
  -- ── SHIPPER (14) ──────────────────────────────────────────
  (137,'Dương Bá Đạt',   'shipper',   NULL, true, '1037', 'badat'),
  (138,'Cao Văn Hậu',    'shipper',   NULL, true, '1038', 'vanhau'),
  (139,'Hồ Quang Huy',   'shipper',   NULL, true, '1039', 'quanghuy'),
  (140,'Đinh Trọng Khang','shipper',  NULL, true, '1040', 'trongkhang'),
  (141,'Tô Đăng Lâm',    'shipper',   NULL, true, '1041', 'danglam'),
  (142,'Lương Thành Long','shipper',  NULL, true, '1042', 'thanhlong'),
  (143,'Võ Hoàng Nam',   'shipper',   NULL, true, '1043', 'hoangnam'),
  (144,'Nguyễn Tấn Phát','shipper',   NULL, true, '1044', 'tanphat'),
  (145,'Trần Hồng Quân', 'shipper',   NULL, true, '1045', 'hongquan'),
  (146,'Lê Minh Sang',   'shipper',   NULL, true, '1046', 'minhsang'),
  (147,'Phạm Văn Tài',   'shipper',   NULL, true, '1047', 'vantai'),
  (148,'Hoàng Anh Tuấn', 'shipper',   NULL, true, '1048', 'anhtuan'),
  (149,'Vũ Quốc Việt',   'shipper',   NULL, true, '1049', 'quocviet'),
  (150,'Đặng Hải Yến',   'shipper',   NULL, true, '1050', 'haiyen')
ON CONFLICT (id) DO NOTHING;

-- ── Đồng bộ sequence id (nếu bảng dùng identity/sequence) ──────────
-- Bỏ qua nếu id được cấp tay. Chạy nếu sau này thêm người không chỉ định id:
-- SELECT setval(pg_get_serial_sequence('staff','id'), (SELECT MAX(id) FROM staff));

-- ── Kiểm tra nhanh ────────────────────────────────────────────────
-- SELECT role, COUNT(*) FROM staff GROUP BY role ORDER BY role;
