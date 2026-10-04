# Accounting Core - Developer & Agent Instructions

## 1. Project Overview & Objective
Xây dựng Lõi Kế toán Kép (Double-Entry Accounting Core) bất biến (Immutable), đảm bảo Zero-Sum Balance (Tổng Debit = Tổng Credit).
Repository: https://github.com/pe-oss/Double-entry-accounting-core.git

## 2. Technical Stack & Environment
- Database: PostgreSQL 16 (chạy qua Docker Compose tại `docker/docker-compose.yml`, múi giờ UTC).
- Datatypes: Sử dụng NUMERIC(18, 4) cho toàn bộ giá trị tiền tệ.
- Migrations: Quản lý lược đồ CSDL bằng Alembic hoặc Flyway.

## 3. Git & Branching Conventions
- Không commit trực tiếp lên `main` và `develop`.
- Tạo nhánh tính năng theo cú pháp: `feature/<module>-<short-description>` (Ví dụ: `feature/ph01-coa-schema`).
- Commit message chuẩn: `<type>(<module>): <message>` (Ví dụ: `feat(coa): add sp_create_account stored procedure`).

## 4. Current Target: Subsystem 1 (Chart of Accounts - COA)
- Quản lý cấu trúc cây tài khoản (Adjacency List + Materialized Path).
- 5 nhóm tài khoản: ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE.
- Ràng buộc: Chỉ tài khoản lá (`is_leaf = true`) và đang hoạt động (`is_active = true`) mới được hạch toán.
- Không tính toán hoặc lưu trữ số dư trong bảng `accounts`.