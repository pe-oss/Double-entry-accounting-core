-- =============================================================================
-- Seed Data: Hệ thống Tài khoản Kế toán Doanh nghiệp (Thông tư 200/2014/TT-BTC)
-- Quản lý theo Adjacency List (parent_id) + Materialized Path (path)
-- Bảng tài khoản: accounts
-- =============================================================================

-- Tạm thời tạo bảng tạm chứa dữ liệu thô (raw catalog)
CREATE TEMP TABLE raw_tt200 (
    code VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL,
    balance VARCHAR(10) NOT NULL,
    parent_code VARCHAR(50) NULL,
    is_contra BOOLEAN DEFAULT FALSE,
    description TEXT NULL
);

-- =============================================================================
-- LOẠI 1: TÀI SẢN NGẮN HẠN (ASSET / DEBIT)
-- =============================================================================
INSERT INTO raw_tt200 (code, name, type, balance, parent_code, is_contra, description) VALUES
-- 111. Tiền mặt
('111', 'Tiền mặt', 'ASSET', 'DEBIT', NULL, FALSE, 'Tài khoản phản ánh tiền mặt tại quỹ'),
('1111', 'Tiền Việt Nam', 'ASSET', 'DEBIT', '111', FALSE, 'Tiền đồng Việt Nam tại quỹ'),
('1112', 'Ngoại tệ', 'ASSET', 'DEBIT', '111', FALSE, 'Ngoại tệ quy đổi theo tỷ giá'),
('1113', 'Vàng tiền tệ', 'ASSET', 'DEBIT', '111', FALSE, 'Vàng sử dụng với mục đích cất trữ giá trị'),

-- 112. Tiền gửi ngân hàng
('112', 'Tiền gửi ngân hàng', 'ASSET', 'DEBIT', NULL, FALSE, 'Tiền gửi tại các tổ chức tín dụng'),
('1121', 'Tiền Việt Nam gửi ngân hàng', 'ASSET', 'DEBIT', '112', FALSE, 'Tiền Việt Nam gửi không kỳ hạn/có kỳ hạn'),
('1122', 'Ngoại tệ gửi ngân hàng', 'ASSET', 'DEBIT', '112', FALSE, 'Ngoại tệ gửi tại ngân hàng'),
('1123', 'Vàng tiền tệ gửi ngân hàng', 'ASSET', 'DEBIT', '112', FALSE, 'Vàng gửi tại ngân hàng'),

-- 113. Tiền đang chuyển
('113', 'Tiền đang chuyển', 'ASSET', 'DEBIT', NULL, FALSE, 'Các khoản tiền đã nộp nhưng chưa nhận được giấy báo có'),
('1131', 'Tiền Việt Nam đang chuyển', 'ASSET', 'DEBIT', '113', FALSE, NULL),
('1132', 'Ngoại tệ đang chuyển', 'ASSET', 'DEBIT', '113', FALSE, NULL),

-- 121. Chứng khoán kinh doanh
('121', 'Chứng khoán kinh doanh', 'ASSET', 'DEBIT', NULL, FALSE, 'Cổ phiếu, trái phiếu nắm giữ chờ bán'),
('1211', 'Cổ phiếu', 'ASSET', 'DEBIT', '121', FALSE, NULL),
('1212', 'Trái phiếu', 'ASSET', 'DEBIT', '121', FALSE, NULL),
('1218', 'Chứng khoán và công cụ tài chính khác', 'ASSET', 'DEBIT', '121', FALSE, NULL),

-- 128. Đầu tư nắm giữ đến ngày đáo hạn
('128', 'Đầu tư nắm giữ đến ngày đáo hạn', 'ASSET', 'DEBIT', NULL, FALSE, 'Tiền gửi có kỳ hạn, trái phiếu, thương phiếu'),
('1281', 'Tiền gửi có kỳ hạn', 'ASSET', 'DEBIT', '128', FALSE, NULL),
('1282', 'Trái phiếu', 'ASSET', 'DEBIT', '128', FALSE, NULL),
('1283', 'Cho vay', 'ASSET', 'DEBIT', '128', FALSE, NULL),
('1288', 'Các khoản đầu tư khác nắm giữ đến ngày đáo hạn', 'ASSET', 'DEBIT', '128', FALSE, NULL),

-- 131. Phải thu của khách hàng
('131', 'Phải thu của khách hàng', 'ASSET', 'DEBIT', NULL, FALSE, 'Theo dõi chi tiết theo từng đối tượng khách hàng'),

-- 133. Thuế GTGT được khấu trừ
('133', 'Thuế GTGT được khấu trừ', 'ASSET', 'DEBIT', NULL, FALSE, 'Thuế GTGT đầu vào được khấu trừ'),
('1331', 'Thuế GTGT được khấu trừ của hàng hóa, dịch vụ', 'ASSET', 'DEBIT', '133', FALSE, NULL),
('1332', 'Thuế GTGT được khấu trừ của TSCĐ', 'ASSET', 'DEBIT', '133', FALSE, NULL),

-- 136. Phải thu nội bộ
('136', 'Phải thu nội bộ', 'ASSET', 'DEBIT', NULL, FALSE, 'Phải thu giữa các đơn vị trực thuộc'),
('1361', 'Vốn kinh doanh ở các đơn vị trực thuộc', 'ASSET', 'DEBIT', '136', FALSE, NULL),
('1362', 'Phải thu nội bộ về chênh lệch tỷ giá', 'ASSET', 'DEBIT', '136', FALSE, NULL),
('1363', 'Phải thu nội bộ về chi phí đi vay đủ điều kiện vốn hóa', 'ASSET', 'DEBIT', '136', FALSE, NULL),
('1368', 'Phải thu nội bộ khác', 'ASSET', 'DEBIT', '136', FALSE, NULL),

-- 138. Phải thu khác
('138', 'Phải thu khác', 'ASSET', 'DEBIT', NULL, FALSE, 'Các khoản phải thu ngoài hoạt động SXKD chính'),
('1381', 'Tài sản thiếu chờ xử lý', 'ASSET', 'DEBIT', '138', FALSE, NULL),
('1385', 'Phải thu về cổ phần hóa', 'ASSET', 'DEBIT', '138', FALSE, NULL),
('1388', 'Phải thu khác', 'ASSET', 'DEBIT', '138', FALSE, NULL),

-- 141. Tạm ứng
('141', 'Tạm ứng', 'ASSET', 'DEBIT', NULL, FALSE, 'Tạm ứng cho người lao động trong doanh nghiệp'),

-- 151. Hàng mua đang đi đường
('151', 'Hàng mua đang đi đường', 'ASSET', 'DEBIT', NULL, FALSE, 'Hàng hóa, vật tư đã mua nhưng chưa về nhập kho'),

-- 152. Nguyên liệu, vật liệu
('152', 'Nguyên liệu, vật liệu', 'ASSET', 'DEBIT', NULL, FALSE, 'Nguyên vật liệu phục vụ sản xuất'),

-- 153. Công cụ, dụng cụ
('153', 'Công cụ, dụng cụ', 'ASSET', 'DEBIT', NULL, FALSE, 'Công cụ, dụng cụ trong kho và đang dùng'),
('1531', 'Công cụ, dụng cụ', 'ASSET', 'DEBIT', '153', FALSE, NULL),
('1532', 'Bao bì luân chuyển', 'ASSET', 'DEBIT', '153', FALSE, NULL),
('1533', 'Đồ dùng cho thuê', 'ASSET', 'DEBIT', '153', FALSE, NULL),
('1534', 'Thiết bị, phụ tùng thay thế', 'ASSET', 'DEBIT', '153', FALSE, NULL),

-- 154. Chi phí sản xuất, kinh doanh dở dang
('154', 'Chi phí sản xuất, kinh doanh dở dang', 'ASSET', 'DEBIT', NULL, FALSE, 'Tập hợp chi phí SXKD dở dang'),

-- 155. Thành phẩm
('155', 'Thành phẩm', 'ASSET', 'DEBIT', NULL, FALSE, 'Thành phẩm chế tạo và thành phẩm BĐS'),
('1551', 'Thành phẩm nhập kho', 'ASSET', 'DEBIT', '155', FALSE, NULL),
('1552', 'Thành phẩm bất động sản', 'ASSET', 'DEBIT', '155', FALSE, NULL),

-- 156. Hàng hóa
('156', 'Hàng hóa', 'ASSET', 'DEBIT', NULL, FALSE, 'Hàng hóa mua về để bán'),
('1561', 'Giá mua hàng hóa', 'ASSET', 'DEBIT', '156', FALSE, NULL),
('1562', 'Chi phí thu mua hàng hóa', 'ASSET', 'DEBIT', '156', FALSE, NULL),
('1567', 'Hàng hóa bất động sản', 'ASSET', 'DEBIT', '156', FALSE, NULL),

-- 157. Hàng gửi đi bán
('157', 'Hàng gửi đi bán', 'ASSET', 'DEBIT', NULL, FALSE, 'Hàng gửi đại lý hoặc gửi cho khách hàng chưa xác định tiêu thụ'),

-- 158. Hàng hóa kho bảo thuế
('158', 'Hàng hóa kho bảo thuế', 'ASSET', 'DEBIT', NULL, FALSE, 'Hàng hóa đưa vào kho bảo thuế'),

-- 229. Dự phòng tổn thất tài sản (Phản ánh trong nhóm ASSET nhưng là Contra-Asset -> normal_balance CREDIT)
('229', 'Dự phòng tổn thất tài sản', 'ASSET', 'CREDIT', NULL, TRUE, 'Tài khoản điều chỉnh giảm tài sản'),
('2291', 'Dự phòng giảm giá chứng khoán kinh doanh', 'ASSET', 'CREDIT', '229', TRUE, NULL),
('2292', 'Dự phòng tổn thất đầu tư vào đơn vị khác', 'ASSET', 'CREDIT', '229', TRUE, NULL),
('2293', 'Dự phòng phải thu khó đòi', 'ASSET', 'CREDIT', '229', TRUE, NULL),
('2294', 'Dự phòng giảm giá hàng tồn kho', 'ASSET', 'CREDIT', '229', TRUE, NULL);

-- =============================================================================
-- LOẠI 2: TÀI SẢN DÀI HẠN (ASSET / DEBIT)
-- =============================================================================
INSERT INTO raw_tt200 (code, name, type, balance, parent_code, is_contra, description) VALUES
-- 211. Tài sản cố định hữu hình
('211', 'Tài sản cố định hữu hình', 'ASSET', 'DEBIT', NULL, FALSE, 'Nguyên giá TSCĐ hữu hình'),
('2111', 'Nhà cửa, vật kiến trúc', 'ASSET', 'DEBIT', '211', FALSE, NULL),
('2112', 'Máy móc, thiết bị', 'ASSET', 'DEBIT', '211', FALSE, NULL),
('2113', 'Phương tiện vận tải, truyền dẫn', 'ASSET', 'DEBIT', '211', FALSE, NULL),
('2118', 'TSCĐ khác', 'ASSET', 'DEBIT', '211', FALSE, NULL),

-- 212. Tài sản cố định thuê tài chính
('212', 'Tài sản cố định thuê tài chính', 'ASSET', 'DEBIT', NULL, FALSE, 'TSCĐ đi thuê tài chính'),
('2121', 'TSCĐ hữu hình thuê tài chính', 'ASSET', 'DEBIT', '212', FALSE, NULL),
('2122', 'TSCĐ vô hình thuê tài chính', 'ASSET', 'DEBIT', '212', FALSE, NULL),

-- 213. Tài sản cố định vô hình
('213', 'Tài sản cố định vô hình', 'ASSET', 'DEBIT', NULL, FALSE, 'Nguyên giá TSCĐ vô hình'),
('2131', 'Quyền sử dụng đất', 'ASSET', 'DEBIT', '213', FALSE, NULL),
('2132', 'Quyền phát hành', 'ASSET', 'DEBIT', '213', FALSE, NULL),
('2133', 'Bản quyền, bằng sáng chế', 'ASSET', 'DEBIT', '213', FALSE, NULL),
('2134', 'Nhãn hiệu hàng hóa', 'ASSET', 'DEBIT', '213', FALSE, NULL),
('2135', 'Phần mềm máy vi tính', 'ASSET', 'DEBIT', '213', FALSE, NULL),
('2138', 'TSCĐ vô hình khác', 'ASSET', 'DEBIT', '213', FALSE, NULL),

-- 214. Hao mòn tài sản cố định (Contra-Asset -> normal_balance CREDIT)
('214', 'Hao mòn tài sản cố định', 'ASSET', 'CREDIT', NULL, TRUE, 'Tài khoản điều chỉnh giảm nguyên giá TSCĐ'),
('2141', 'Hao mòn TSCĐ hữu hình', 'ASSET', 'CREDIT', '214', TRUE, NULL),
('2142', 'Hao mòn TSCĐ thuê tài chính', 'ASSET', 'CREDIT', '214', TRUE, NULL),
('2143', 'Hao mòn TSCĐ vô hình', 'ASSET', 'CREDIT', '214', TRUE, NULL),
('2147', 'Hao mòn bất động sản đầu tư', 'ASSET', 'CREDIT', '214', TRUE, NULL),

-- 217. Bất động sản đầu tư
('217', 'Bất động sản đầu tư', 'ASSET', 'DEBIT', NULL, FALSE, 'BĐS nắm giữ để chờ tăng giá hoặc cho thuê'),

-- 221. Đầu tư vào công ty con
('221', 'Đầu tư vào công ty con', 'ASSET', 'DEBIT', NULL, FALSE, 'Vốn đầu tư nắm giữ quyền kiểm soát'),

-- 222. Đầu tư vào công ty liên doanh, liên kết
('222', 'Đầu tư vào công ty liên doanh, liên kết', 'ASSET', 'DEBIT', NULL, FALSE, 'Vốn nắm giữ ảnh hưởng đáng kể'),

-- 228. Đầu tư khác
('228', 'Đầu tư khác', 'ASSET', 'DEBIT', NULL, FALSE, 'Góp vốn vào đơn vị khác'),
('2281', 'Đầu tư vào công cụ vốn của đơn vị khác', 'ASSET', 'DEBIT', '228', FALSE, NULL),
('2288', 'Đầu tư khác', 'ASSET', 'DEBIT', '228', FALSE, NULL),

-- 241. Xây dựng cơ bản dở dang
('241', 'Xây dựng cơ bản dở dang', 'ASSET', 'DEBIT', NULL, FALSE, 'Chi phí mua sắm TSCĐ và XDCB dở dang'),
('2411', 'Mua sắm TSCĐ', 'ASSET', 'DEBIT', '241', FALSE, NULL),
('2412', 'Xây dựng cơ bản', 'ASSET', 'DEBIT', '241', FALSE, NULL),
('2413', 'Sửa chữa lớn TSCĐ', 'ASSET', 'DEBIT', '241', FALSE, NULL),

-- 242. Chi phí trả trước
('242', 'Chi phí trả trước', 'ASSET', 'DEBIT', NULL, FALSE, 'Chi phí trả trước phân bổ dần'),

-- 243. Tài sản thuế thu nhập hoãn lại
('243', 'Tài sản thuế thu nhập hoãn lại', 'ASSET', 'DEBIT', NULL, FALSE, 'Tài sản thuế TNDN hoãn lại phát sinh'),

-- 244. Cầm cố, thế chấp, ký quỹ, ký cược
('244', 'Cầm cố, thế chấp, ký quỹ, ký cược', 'ASSET', 'DEBIT', NULL, FALSE, 'Các khoản tài sản mang đi bảo đảm');

-- =============================================================================
-- LOẠI 3: NỢ PHẢI TRẢ (LIABILITY / CREDIT)
-- =============================================================================
INSERT INTO raw_tt200 (code, name, type, balance, parent_code, is_contra, description) VALUES
-- 331. Phải trả cho người bán
('331', 'Phải trả cho người bán', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Chi tiết theo từng đối tượng người bán'),

-- 333. Thuế và các khoản phải nộp Nhà nước
('333', 'Thuế và các khoản phải nộp Nhà nước', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Nghĩa vụ thuế đối với ngân sách nhà nước'),
('3331', 'Thuế giá trị gia tăng phải nộp', 'LIABILITY', 'CREDIT', '333', FALSE, NULL),
('33311', 'Thuế GTGT đầu ra', 'LIABILITY', 'CREDIT', '3331', FALSE, NULL),
('33312', 'Thuế GTGT hàng nhập khẩu', 'LIABILITY', 'CREDIT', '3331', FALSE, NULL),
('3332', 'Thuế tiêu thụ đặc biệt', 'LIABILITY', 'CREDIT', '333', FALSE, NULL),
('3333', 'Thuế xuất, nhập khẩu', 'LIABILITY', 'CREDIT', '333', FALSE, NULL),
('3334', 'Thuế thu nhập doanh nghiệp', 'LIABILITY', 'CREDIT', '333', FALSE, NULL),
('3335', 'Thuế thu nhập cá nhân', 'LIABILITY', 'CREDIT', '333', FALSE, NULL),
('3336', 'Thuế tài nguyên', 'LIABILITY', 'CREDIT', '333', FALSE, NULL),
('3337', 'Thuế nhà đất, tiền thuê đất', 'LIABILITY', 'CREDIT', '333', FALSE, NULL),
('3338', 'Thuế bảo vệ môi trường và các loại thuế khác', 'LIABILITY', 'CREDIT', '333', FALSE, NULL),
('3339', 'Phí, lệ phí và các khoản phải nộp khác', 'LIABILITY', 'CREDIT', '333', FALSE, NULL),

-- 334. Phải trả người lao động
('334', 'Phải trả người lao động', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Tiền lương, thù lao, thưởng cho người lao động'),
('3341', 'Phải trả công nhân viên', 'LIABILITY', 'CREDIT', '334', FALSE, NULL),
('3348', 'Phải trả người lao động khác', 'LIABILITY', 'CREDIT', '334', FALSE, NULL),

-- 335. Chi phí phải trả
('335', 'Chi phí phải trả', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Các khoản trích trước vào chi phí sản xuất kinh doanh'),

-- 336. Phải trả nội bộ
('336', 'Phải trả nội bộ', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Nợ phải trả giữa đơn vị cấp trên và trực thuộc'),
('3361', 'Phải trả nội bộ về vốn kinh doanh', 'LIABILITY', 'CREDIT', '336', FALSE, NULL),
('3362', 'Phải trả nội bộ về chênh lệch tỷ giá', 'LIABILITY', 'CREDIT', '336', FALSE, NULL),
('3363', 'Phải trả nội bộ về chi phí đi vay đủ điều kiện vốn hóa', 'LIABILITY', 'CREDIT', '336', FALSE, NULL),
('3368', 'Phải trả nội bộ khác', 'LIABILITY', 'CREDIT', '336', FALSE, NULL),

-- 337. Thanh toán theo tiến độ hợp đồng xây dựng
('337', 'Thanh toán theo tiến độ hợp đồng xây dựng', 'LIABILITY', 'CREDIT', NULL, FALSE, NULL),

-- 338. Phải trả, phải nộp khác
('338', 'Phải trả, phải nộp khác', 'LIABILITY', 'CREDIT', NULL, FALSE, 'BHXH, BHYT, KPCĐ, BHTN, cổ tức, tài sản thừa'),
('3381', 'Tài sản thừa chờ giải quyết', 'LIABILITY', 'CREDIT', '338', FALSE, NULL),
('3382', 'Kinh phí công đoàn', 'LIABILITY', 'CREDIT', '338', FALSE, NULL),
('3383', 'Bảo hiểm xã hội', 'LIABILITY', 'CREDIT', '338', FALSE, NULL),
('3384', 'Bảo hiểm y tế', 'LIABILITY', 'CREDIT', '338', FALSE, NULL),
('3385', 'Phải trả về cổ phần hóa', 'LIABILITY', 'CREDIT', '338', FALSE, NULL),
('3386', 'Bảo hiểm thất nghiệp', 'LIABILITY', 'CREDIT', '338', FALSE, NULL),
('3387', 'Doanh thu chưa thực hiện', 'LIABILITY', 'CREDIT', '338', FALSE, NULL),
('3388', 'Phải trả, phải nộp khác', 'LIABILITY', 'CREDIT', '338', FALSE, NULL),

-- 341. Vay và nợ thuê tài chính
('341', 'Vay và nợ thuê tài chính', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Các khoản vay ngân hàng và tổ chức tài chính'),
('3411', 'Các khoản đi vay', 'LIABILITY', 'CREDIT', '341', FALSE, NULL),
('3412', 'Nợ thuê tài chính', 'LIABILITY', 'CREDIT', '341', FALSE, NULL),

-- 343. Trái phiếu phát hành
('343', 'Trái phiếu phát hành', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Mệnh giá và chiết khấu/phụ trội trái phiếu'),
('3431', 'Trái phiếu thường', 'LIABILITY', 'CREDIT', '343', FALSE, NULL),
('34311', 'Mệnh giá trái phiếu', 'LIABILITY', 'CREDIT', '3431', FALSE, NULL),
('34312', 'Chiết khấu trái phiếu', 'LIABILITY', 'CREDIT', '3431', TRUE, 'Khoản điều chỉnh giảm nợ trái phiếu'),
('34313', 'Phụ trội trái phiếu', 'LIABILITY', 'CREDIT', '3431', FALSE, NULL),
('3432', 'Trái phiếu chuyển đổi', 'LIABILITY', 'CREDIT', '343', FALSE, NULL),

-- 344. Nhận ký quỹ, ký cược
('344', 'Nhận ký quỹ, ký cược', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Các khoản nhận ký quỹ bảo đảm'),

-- 347. Thuế thu nhập hoãn lại phải trả
('347', 'Thuế thu nhập hoãn lại phải trả', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Nợ thuế TNDN hoãn lại'),

-- 352. Dự phòng phải trả
('352', 'Dự phòng phải trả', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Dự phòng bảo hành sản phẩm, tái cơ cấu'),
('3521', 'Dự phòng bảo hành sản phẩm, hàng hóa', 'LIABILITY', 'CREDIT', '352', FALSE, NULL),
('3522', 'Dự phòng bảo hành công trình xây dựng', 'LIABILITY', 'CREDIT', '352', FALSE, NULL),
('3523', 'Dự phòng tái cơ cấu doanh nghiệp', 'LIABILITY', 'CREDIT', '352', FALSE, NULL),
('3524', 'Dự phòng phải trả khác', 'LIABILITY', 'CREDIT', '352', FALSE, NULL),

-- 353. Quỹ khen thưởng, phúc lợi
('353', 'Quỹ khen thưởng, phúc lợi', 'LIABILITY', 'CREDIT', NULL, FALSE, 'Quỹ phúc lợi, khen thưởng cho cán bộ nhân viên'),
('3531', 'Quỹ khen thưởng', 'LIABILITY', 'CREDIT', '353', FALSE, NULL),
('3532', 'Quỹ phúc lợi', 'LIABILITY', 'CREDIT', '353', FALSE, NULL),
('3533', 'Quỹ phúc lợi đã hình thành TSCĐ', 'LIABILITY', 'CREDIT', '353', FALSE, NULL),
('3534', 'Quỹ thưởng ban quản lý điều hành công ty', 'LIABILITY', 'CREDIT', '353', FALSE, NULL),

-- 356. Quỹ phát triển khoa học và công nghệ
('356', 'Quỹ phát triển khoa học và công nghệ', 'LIABILITY', 'CREDIT', NULL, FALSE, NULL),
('3561', 'Quỹ phát triển KH và CN', 'LIABILITY', 'CREDIT', '356', FALSE, NULL),
('3562', 'Quỹ phát triển KH và CN đã hình thành TSCĐ', 'LIABILITY', 'CREDIT', '356', FALSE, NULL);

-- =============================================================================
-- LOẠI 4: VỐN CHỦ SỞ HỮU (EQUITY / CREDIT)
-- =============================================================================
INSERT INTO raw_tt200 (code, name, type, balance, parent_code, is_contra, description) VALUES
-- 411. Vốn đầu tư của chủ sở hữu
('411', 'Vốn đầu tư của chủ sở hữu', 'EQUITY', 'CREDIT', NULL, FALSE, 'Vốn góp thực tế của các cổ đông/chủ sở hữu'),
('4111', 'Vốn góp của chủ sở hữu', 'EQUITY', 'CREDIT', '411', FALSE, NULL),
('4112', 'Thặng dư vốn cổ phần', 'EQUITY', 'CREDIT', '411', FALSE, NULL),
('4113', 'Quyền chọn chuyển đổi trái phiếu', 'EQUITY', 'CREDIT', '411', FALSE, NULL),
('4118', 'Vốn khác', 'EQUITY', 'CREDIT', '411', FALSE, NULL),

-- 412. Chênh lệch đánh giá lại tài sản
('412', 'Chênh lệch đánh giá lại tài sản', 'EQUITY', 'CREDIT', NULL, FALSE, NULL),

-- 413. Chênh lệch tỷ giá hối đoái
('413', 'Chênh lệch tỷ giá hối đoái', 'EQUITY', 'CREDIT', NULL, FALSE, NULL),
('4131', 'Chênh lệch tỷ giá đánh giá lại các khoản mục tiền tệ có gốc ngoại tệ', 'EQUITY', 'CREDIT', '413', FALSE, NULL),
('4132', 'Chênh lệch tỷ giá trong giai đoạn trước hoạt động', 'EQUITY', 'CREDIT', '413', FALSE, NULL),

-- 414. Quỹ đầu tư phát triển
('414', 'Quỹ đầu tư phát triển', 'EQUITY', 'CREDIT', NULL, FALSE, 'Quỹ trích lập từ lợi nhuận sau thuế'),

-- 417. Quỹ hỗ trợ sắp xếp doanh nghiệp
('417', 'Quỹ hỗ trợ sắp xếp doanh nghiệp', 'EQUITY', 'CREDIT', NULL, FALSE, NULL),

-- 418. Các quỹ khác thuộc vốn chủ sở hữu
('418', 'Các quỹ khác thuộc vốn chủ sở hữu', 'EQUITY', 'CREDIT', NULL, FALSE, NULL),

-- 419. Cổ phiếu quỹ (Contra-Equity -> normal_balance DEBIT)
('419', 'Cổ phiếu quỹ', 'EQUITY', 'DEBIT', NULL, TRUE, 'Giá trị cổ phiếu do chính DN mua lại làm giảm vốn chủ sở hữu'),

-- 421. Lợi nhuận sau thuế chưa phân phối
('421', 'Lợi nhuận sau thuế chưa phân phối', 'EQUITY', 'CREDIT', NULL, FALSE, 'Kết quả kinh doanh lũy kế chưa chia'),
('4211', 'Lợi nhuận sau thuế chưa phân phối năm trước', 'EQUITY', 'CREDIT', '421', FALSE, NULL),
('4212', 'Lợi nhuận sau thuế chưa phân phối năm nay', 'EQUITY', 'CREDIT', '421', FALSE, NULL),

-- 441. Nguồn vốn đầu tư xây dựng cơ bản
('441', 'Nguồn vốn đầu tư xây dựng cơ bản', 'EQUITY', 'CREDIT', NULL, FALSE, NULL),

-- 461. Nguồn kinh phí sự nghiệp
('461', 'Nguồn kinh phí sự nghiệp', 'EQUITY', 'CREDIT', NULL, FALSE, NULL),
('4611', 'Nguồn kinh phí sự nghiệp năm trước', 'EQUITY', 'CREDIT', '461', FALSE, NULL),
('4612', 'Nguồn kinh phí sự nghiệp năm nay', 'EQUITY', 'CREDIT', '461', FALSE, NULL),

-- 466. Nguồn kinh phí đã hình thành TSCĐ
('466', 'Nguồn kinh phí đã hình thành TSCĐ', 'EQUITY', 'CREDIT', NULL, FALSE, NULL);

-- =============================================================================
-- LOẠI 5: DOANH THU (REVENUE / CREDIT)
-- =============================================================================
INSERT INTO raw_tt200 (code, name, type, balance, parent_code, is_contra, description) VALUES
-- 511. Doanh thu bán hàng và cung cấp dịch vụ
('511', 'Doanh thu bán hàng và cung cấp dịch vụ', 'REVENUE', 'CREDIT', NULL, FALSE, 'Doanh thu hoạt động SXKD chính'),
('5111', 'Doanh thu bán hàng hóa', 'REVENUE', 'CREDIT', '511', FALSE, NULL),
('5112', 'Doanh thu bán các thành phẩm', 'REVENUE', 'CREDIT', '511', FALSE, NULL),
('5113', 'Doanh thu cung cấp dịch vụ', 'REVENUE', 'CREDIT', '511', FALSE, NULL),
('5114', 'Doanh thu trợ cấp, trợ giá', 'REVENUE', 'CREDIT', '511', FALSE, NULL),
('5117', 'Doanh thu kinh doanh bất động sản đầu tư', 'REVENUE', 'CREDIT', '511', FALSE, NULL),
('5118', 'Doanh thu khác', 'REVENUE', 'CREDIT', '511', FALSE, NULL),

-- 515. Doanh thu hoạt động tài chính
('515', 'Doanh thu hoạt động tài chính', 'REVENUE', 'CREDIT', NULL, FALSE, 'Tiền lãi, cổ tức, chênh lệch tỷ giá lãi'),

-- 521. Các khoản giảm trừ doanh thu (Contra-Revenue -> normal_balance DEBIT)
('521', 'Các khoản giảm trừ doanh thu', 'REVENUE', 'DEBIT', NULL, TRUE, 'Điều chỉnh giảm doanh thu bán hàng'),
('5211', 'Chiết khấu thương mại', 'REVENUE', 'DEBIT', '521', TRUE, NULL),
('5212', 'Hàng bán bị trả lại', 'REVENUE', 'DEBIT', '521', TRUE, NULL),
('5213', 'Giảm giá hàng bán', 'REVENUE', 'DEBIT', '521', TRUE, NULL);

-- =============================================================================
-- LOẠI 6: CHI PHÍ SẢN XUẤT, KINH DOANH (EXPENSE / DEBIT)
-- =============================================================================
INSERT INTO raw_tt200 (code, name, type, balance, parent_code, is_contra, description) VALUES
-- 611. Mua hàng (Phương pháp kiểm kê định kỳ)
('611', 'Mua hàng', 'EXPENSE', 'DEBIT', NULL, FALSE, NULL),
('6111', 'Mua nguyên liệu, vật liệu', 'EXPENSE', 'DEBIT', '611', FALSE, NULL),
('6112', 'Mua hàng hóa', 'EXPENSE', 'DEBIT', '611', FALSE, NULL),

-- 621. Chi phí nguyên liệu, vật liệu trực tiếp
('621', 'Chi phí nguyên liệu, vật liệu trực tiếp', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Chi phí NVL cấu thành sản phẩm'),

-- 622. Chi phí nhân công trực tiếp
('622', 'Chi phí nhân công trực tiếp', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Tiền lương và bảo hiểm công nhân sản xuất trực tiếp'),

-- 623. Chi phí sử dụng máy thi công
('623', 'Chi phí sử dụng máy thi công', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Doanh nghiệp xây lắp'),
('6231', 'Chi phí nhân công máy thi công', 'EXPENSE', 'DEBIT', '623', FALSE, NULL),
('6232', 'Chi phí vật liệu', 'EXPENSE', 'DEBIT', '623', FALSE, NULL),
('6233', 'Chi phí dụng cụ sản xuất', 'EXPENSE', 'DEBIT', '623', FALSE, NULL),
('6234', 'Chi phí khấu hao máy thi công', 'EXPENSE', 'DEBIT', '623', FALSE, NULL),
('6237', 'Chi phí dịch vụ mua ngoài', 'EXPENSE', 'DEBIT', '623', FALSE, NULL),
('6238', 'Chi phí bằng tiền khác', 'EXPENSE', 'DEBIT', '623', FALSE, NULL),

-- 627. Chi phí sản xuất chung
('627', 'Chi phí sản xuất chung', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Chi phí tại phân xưởng sản xuất'),
('6271', 'Chi phí nhân viên phân xưởng', 'EXPENSE', 'DEBIT', '627', FALSE, NULL),
('6272', 'Chi phí vật liệu phân xưởng', 'EXPENSE', 'DEBIT', '627', FALSE, NULL),
('6273', 'Chi phí dụng cụ sản xuất', 'EXPENSE', 'DEBIT', '627', FALSE, NULL),
('6274', 'Chi phí khấu hao TSCĐ', 'EXPENSE', 'DEBIT', '627', FALSE, NULL),
('6277', 'Chi phí dịch vụ mua ngoài', 'EXPENSE', 'DEBIT', '627', FALSE, NULL),
('6278', 'Chi phí bằng tiền khác', 'EXPENSE', 'DEBIT', '627', FALSE, NULL),

-- 631. Giá thành sản xuất (Kiểm kê định kỳ)
('631', 'Giá thành sản xuất', 'EXPENSE', 'DEBIT', NULL, FALSE, NULL),

-- 632. Giá vốn hàng bán
('632', 'Giá vốn hàng bán', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Giá vốn thành phẩm, hàng hóa tiêu thụ trong kỳ'),

-- 635. Chi phí tài chính
('635', 'Chi phí tài chính', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Lãi tiền vay, lỗ tỷ giá phát sinh'),

-- 641. Chi phí bán hàng
('641', 'Chi phí bán hàng', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Chi phí tiêu thụ sản phẩm, hàng hóa, dịch vụ'),
('6411', 'Chi phí nhân viên bán hàng', 'EXPENSE', 'DEBIT', '641', FALSE, NULL),
('6412', 'Chi phí vật liệu, bao bì', 'EXPENSE', 'DEBIT', '641', FALSE, NULL),
('6413', 'Chi phí dụng cụ, đồ dùng', 'EXPENSE', 'DEBIT', '641', FALSE, NULL),
('6414', 'Chi phí khấu hao TSCĐ', 'EXPENSE', 'DEBIT', '641', FALSE, NULL),
('6415', 'Chi phí bảo hành', 'EXPENSE', 'DEBIT', '641', FALSE, NULL),
('6417', 'Chi phí dịch vụ mua ngoài', 'EXPENSE', 'DEBIT', '641', FALSE, NULL),
('6418', 'Chi phí bằng tiền khác', 'EXPENSE', 'DEBIT', '641', FALSE, NULL),

-- 642. Chi phí quản lý doanh nghiệp
('642', 'Chi phí quản lý doanh nghiệp', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Chi phí quản lý chung của toàn doanh nghiệp'),
('6421', 'Chi phí nhân viên quản lý', 'EXPENSE', 'DEBIT', '642', FALSE, NULL),
('6422', 'Chi phí vật liệu quản lý', 'EXPENSE', 'DEBIT', '642', FALSE, NULL),
('6423', 'Chi phí đồ dùng văn phòng', 'EXPENSE', 'DEBIT', '642', FALSE, NULL),
('6424', 'Chi phí khấu hao TSCĐ', 'EXPENSE', 'DEBIT', '642', FALSE, NULL),
('6425', 'Thuế, phí và lệ phí', 'EXPENSE', 'DEBIT', '642', FALSE, NULL),
('6426', 'Chi phí dự phòng', 'EXPENSE', 'DEBIT', '642', FALSE, NULL),
('6427', 'Chi phí dịch vụ mua ngoài', 'EXPENSE', 'DEBIT', '642', FALSE, NULL),
('6428', 'Chi phí bằng tiền khác', 'EXPENSE', 'DEBIT', '642', FALSE, NULL);

-- =============================================================================
-- LOẠI 7: THU NHẬP KHÁC (REVENUE / CREDIT)
-- =============================================================================
INSERT INTO raw_tt200 (code, name, type, balance, parent_code, is_contra, description) VALUES
('711', 'Thu nhập khác', 'REVENUE', 'CREDIT', NULL, FALSE, 'Thu nhập thanh lý TSCĐ, thu tiền phạt, tiền bồi thường');

-- =============================================================================
-- LOẠI 8: CHI PHÍ KHÁC VÀ THUẾ TNDN (EXPENSE / DEBIT)
-- =============================================================================
INSERT INTO raw_tt200 (code, name, type, balance, parent_code, is_contra, description) VALUES
-- 811. Chi phí khác
('811', 'Chi phí khác', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Chi phí thanh lý nhượng bán TSCĐ, tiền phạt vi phạm'),

-- 821. Chi phí thuế thu nhập doanh nghiệp
('821', 'Chi phí thuế thu nhập doanh nghiệp', 'EXPENSE', 'DEBIT', NULL, FALSE, 'Chi phí thuế TNDN hiện hành và hoãn lại'),
('8211', 'Chi phí thuế TNDN hiện hành', 'EXPENSE', 'DEBIT', '821', FALSE, NULL),
('8212', 'Chi phí thuế TNDN hoãn lại', 'EXPENSE', 'DEBIT', '821', FALSE, NULL);

-- =============================================================================
-- LOẠI 9: XÁC ĐỊNH KẾT QUẢ KINH DOANH (EQUITY / CREDIT)
-- =============================================================================
INSERT INTO raw_tt200 (code, name, type, balance, parent_code, is_contra, description) VALUES
('911', 'Xác định kết quả kinh doanh', 'EQUITY', 'CREDIT', NULL, FALSE, 'Tài khoản trung gian kết chuyển doanh thu và chi phí để xác định lãi/lỗ');


-- =============================================================================
-- BƯỚC THỰC THI NẠP: NẠP THEO ĐỆ QUY CÂY (CHA TRƯỚC -> CON SAU)
-- Đảm bảo depth, path, parent_id, is_leaf chính xác tuyệt đối!
-- =============================================================================

DO $$
DECLARE
    v_level INT := 1;
    v_inserted INT := 0;
BEGIN
    RAISE NOTICE 'Bắt đầu nạp dữ liệu danh mục tài khoản Thông tư 200...';

    -- 1. Nạp các tài khoản cấp 1 (root accounts - depth = 1)
    INSERT INTO accounts (account_code, account_name, account_type, normal_balance, parent_id,
                          is_leaf, is_contra, is_active, depth, path, description)
    SELECT
        r.code,
        r.name,
        r.type,
        r.balance,
        NULL,
        TRUE,
        r.is_contra,
        TRUE,
        1,
        '/' || r.code || '/',
        r.description
    FROM raw_tt200 r
    WHERE r.parent_code IS NULL
    ON CONFLICT (account_code) DO NOTHING;

    GET DIAGNOSTICS v_inserted = ROW_COUNT;
    RAISE NOTICE 'Đã nạp cấp 1 (depth=1): % tài khoản', v_inserted;

    -- 2. Lặp nạp các cấp con (depth 2, 3...) theo quan hệ cha-con
    LOOP
        v_level := v_level + 1;

        INSERT INTO accounts (account_code, account_name, account_type, normal_balance, parent_id,
                              is_leaf, is_contra, is_active, depth, path, description)
        SELECT
            r.code,
            r.name,
            r.type,
            r.balance,
            p.id,
            TRUE,
            r.is_contra,
            TRUE,
            p.depth + 1,
            p.path || r.code || '/',
            r.description
        FROM raw_tt200 r
        JOIN accounts p ON p.account_code = r.parent_code
        WHERE NOT EXISTS (SELECT 1 FROM accounts a WHERE a.account_code = r.code)
          AND p.depth = v_level - 1;

        GET DIAGNOSTICS v_inserted = ROW_COUNT;
        EXIT WHEN v_inserted = 0;
        RAISE NOTICE 'Đã nạp cấp % (depth=%): % tài khoản', v_level, v_level, v_inserted;
    END LOOP;

    -- 3. Cập nhật lại cờ is_leaf = FALSE cho các tài khoản cha (có con trực tiếp)
    UPDATE accounts p
    SET is_leaf = FALSE
    WHERE EXISTS (SELECT 1 FROM accounts c WHERE c.parent_id = p.id)
      AND p.is_leaf = TRUE;

    RAISE NOTICE 'Đã cập nhật cờ is_leaf cho toàn bộ cây tài khoản.';
END $$;

-- Xóa bảng tạm
DROP TABLE raw_tt200;
