# NHẬT KÝ VÀ TỔNG KẾT PHIÊN LÀM VIỆC (04/10/2026)
**Dự án:** Lõi Kế toán Kép Bất biến (Double-Entry Accounting Core)  
**Repository GitHub:** [pe-oss/Double-entry-accounting-core](https://github.com/pe-oss/Double-entry-accounting-core.git)  
**Nhánh làm việc hiện tại:** `feature/ph01-coa-schema`  

---

## 1. Những công việc đã hoàn thành hôm nay

### Hạ tầng & Môi trường (Giai đoạn 1)
1. **Đồng bộ tài liệu thiết kế:** Xây dựng script Python [sync_google_docs.py](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/sync_google_docs.py) kết nối Google Drive API (OAuth 2.0 Desktop) tải dữ liệu thiết kế từ Google Docs ([thiet_ke_tu_docs.md](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/thiet_ke_tu_docs.md)) và Google Sheets ([thiet_ke_tu_sheets.csv](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/thiet_ke_tu_sheets.csv)).
2. **Docker & PostgreSQL 16:**
   - Cài đặt và cấu hình Docker Desktop trên Windows.
   - Tạo file [docker/docker-compose.yml](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/docker/docker-compose.yml) chạy container `accounting_core_postgres` (PostgreSQL 16 Alpine, múi giờ chuẩn `UTC`, lưu trữ dữ liệu bền vững qua volume `accounting_core_pgdata`).
   - Tạo mẫu biến môi trường [.env.example](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/.env.example) và file [.env](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/.env) cục bộ an toàn.
3. **Cấu hình Git & Bảo mật:**
   - Khởi tạo Git repo, tạo nhánh `main` và nhánh trung chuyển `develop`.
   - Cấu hình [.gitignore](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/.gitignore) ngăn chặn hoàn toàn việc rò rỉ mã bí mật (`.env`, `credentials.json`, `token.pickle`, `pgdata`).
   - Liên kết remote repository GitHub và đẩy các nhánh lên an toàn.

---

### Cơ sở dữ liệu Hệ thống Tài khoản - COA (Giai đoạn 2 & 3)
1. **Thiết lập công cụ Migration Alembic:**
   - Cài đặt `alembic`, `SQLAlchemy`, `psycopg 3` vào virtual environment (`venv`).
   - Cấu hình [alembic.ini](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/alembic.ini) và [migrations/env.py](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/migrations/env.py) đọc chuỗi kết nối từ biến `DATABASE_URL`.
2. **Migration 0001: Bảng `accounts` (Giai đoạn 2.1):**
   - Tạo bảng `accounts` theo mô hình lai: **Adjacency List (`parent_id`) + Materialized Path (`path`)**.
   - Các cột nghiệp vụ: `account_code`, `account_name`, `account_type` (5 nhóm chuẩn), `normal_balance` (`DEBIT`/`CREDIT`), `is_leaf`, `is_contra`, `is_active`, `depth`, `path`.
   - Các ràng buộc kiểm tra toàn vẹn và chỉ mục b-tree tối ưu hóa tìm kiếm phân cấp cây.
3. **Migration 0002: Stored Procedures Quản trị Cây (Giai đoạn 2.2):**
   - `sp_create_account`: Tự động tính `depth` và `path` (`/cha/con/`), tự động cập nhật tài khoản cha thành tài khoản tổng hợp (`is_leaf = FALSE`).
   - `sp_deactivate_account`: Vô hiệu hóa tài khoản an toàn; chặn hành động nếu tài khoản còn con đang active, còn bút toán DRAFT, hoặc số dư thực tế khác 0.
   - Đã chạy kịch bản kiểm thử tự động, kết quả đạt 100%.
4. **Seed Data Danh mục Tài khoản Thông tư 200/2014/TT-BTC (Giai đoạn 3):**
   - Tạo script [seeds/seed_coa_tt200.sql](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/seeds/seed_coa_tt200.sql) và script nạp/kiểm tra [seeds/seed.py](file:///d:/D%E1%BB%B1%20%C3%A1n/PJ_Loi_ke_toan_kep/seeds/seed.py).
   - Nạp thành công **223 tài khoản** chuẩn từ Loại 1 đến Loại 9 (73 tài khoản cấp 1, 41 tài khoản tổng hợp mẹ, 182 tài khoản lá hạch toán).
   - Thiết lập đúng 16 tài khoản điều chỉnh giảm (**Contra Accounts** như Hao mòn `214`, Dự phòng `229`, Cổ phiếu quỹ `419`, Giảm trừ DT `521`).

---

## 2. Trạng thái hiện tại của hệ thống

- **Database:** Đang chạy ổn định trong Docker tại cổng `localhost:5432`.
- **Dữ liệu:** Đã có đầy đủ danh mục COA Thông tư 200, sẵn sàng cho việc định khoản bút toán và viết API.
- **Git:** Đang ở nhánh `feature/ph01-coa-schema`, các commit đã được push đầy đủ lên GitHub:
  * `4fd188a feat(infra): setup postgres 16 docker compose and env template`
  * `42df0b6 feat(coa): create accounts table migration with constraints and indexes`
  * `b68d7c3 feat(coa): implement sp_create_account and sp_deactivate_account procedures`
  * `4ba0e8d feat(coa): add standard chart of accounts seed data per circular 200`

---

## 3. Hướng dẫn khởi động lại ở phiên sau

Khi mở máy ở phiên làm việc tiếp theo, bạn chỉ cần làm 2 bước đơn giản:

1. **Mở Docker Desktop** (đảm bảo Docker Desktop hiển thị trạng thái "Engine running").
   * *Nếu cần kiểm tra database bằng dòng lệnh:*
     ```powershell
     docker ps
     ```
     (Nếu container chưa chạy: `docker compose -f docker/docker-compose.yml --env-file .env up -d`)
2. **Kích hoạt môi trường Python:**
   ```powershell
   .\venv\Scripts\activate
   ```

---

## 4. Kế hoạch công việc cho phiên tiếp theo

Theo lộ trình thiết kế trong tài liệu, phiên sau chúng ta sẽ tiếp tục với:
1. **Giai đoạn 4 (Tầng Dịch vụ & RESTful API Endpoints):**
   - Tạo nhánh `feature/ph01-coa-api`.
   - Cài đặt `FastAPI` và `uvicorn`.
   - Xây dựng Repository / Service: Hàm lấy cây tài khoản lồng nhau (JSON Tree), hàm lọc tài khoản lá (`isValidPostingAccount`).
   - Xây dựng các Endpoint RESTful:
     * `GET /api/v1/accounts`: Danh sách tài khoản (hỗ trợ lọc).
     * `GET /api/v1/accounts/tree`: Cây tài khoản phân cấp JSON.
     * `POST /api/v1/accounts`: Tạo mới tài khoản (gọi Stored Procedure).
     * `PATCH /api/v1/accounts/{id}/deactivate`: Vô hiệu hóa an toàn.
2. **Giai đoạn 5 (Kiểm thử tự động - Automated Testing):**
   - Viết bộ Test Matrix với `pytest` kiểm thử toàn diện các trường hợp biên, ràng buộc trùng mã, logic cha-con.
