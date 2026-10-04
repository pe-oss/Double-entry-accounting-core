-- Chạy tự động khi DB được khởi tạo lần đầu.
-- Các file schema / stored procedure của PH-01 sẽ được đặt tiếp theo (01_..., 02_...).
CREATE EXTENSION IF NOT EXISTS pgcrypto;
SELECT 'Lõi kế toán kép: PostgreSQL đã sẵn sàng' AS status;
