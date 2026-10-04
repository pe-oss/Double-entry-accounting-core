"""Script chạy seed data nạp danh mục tài khoản Thông tư 200 vào PostgreSQL."""
import os
import psycopg
from dotenv import load_dotenv

load_dotenv()

DB_URL = os.environ.get("DATABASE_URL")
if not DB_URL:
    raise RuntimeError("Chưa khai báo DATABASE_URL trong .env")

# Chuẩn hóa connection string cho psycopg
if DB_URL.startswith("postgresql+psycopg://"):
    DB_URL = DB_URL.replace("postgresql+psycopg://", "postgresql://")

sql_path = os.path.join(os.path.dirname(__file__), "seed_coa_tt200.sql")
with open(sql_path, "r", encoding="utf-8") as f:
    seed_sql = f.read()

print("Đang kết nối database để nạp danh mục tài khoản TT200...")
with psycopg.connect(DB_URL, autocommit=True) as conn:
    with conn.cursor() as cur:
        cur.execute(seed_sql)

    # Kiểm tra tính toàn vẹn cây
    with conn.cursor() as cur:
        total = cur.execute("SELECT count(*) FROM accounts;").fetchone()[0]
        roots = cur.execute("SELECT count(*) FROM accounts WHERE parent_id IS NULL;").fetchone()[0]
        leaves = cur.execute("SELECT count(*) FROM accounts WHERE is_leaf = TRUE;").fetchone()[0]
        parents = cur.execute("SELECT count(*) FROM accounts WHERE is_leaf = FALSE;").fetchone()[0]

        print("\n--- KẾT QUẢ KIỂM TRA TÍNH TOÀN VẸN CÂY TÀI KHOẢN ---")
        print(f"Tổng số tài khoản: {total}")
        print(f"- Số tài khoản gốc (Cấp 1 - depth=1): {roots}")
        print(f"- Số tài khoản mẹ/tổng hợp (is_leaf=False): {parents}")
        print(f"- Số tài khoản lá chi tiết (is_leaf=True, được phép hạch toán): {leaves}")

        # Kiểm tra tính nhất quán nhóm giữa cha và con
        inconsistent_types = cur.execute("""
            SELECT c.account_code, c.account_type, p.account_code, p.account_type
            FROM accounts c
            JOIN accounts p ON p.id = c.parent_id
            WHERE c.account_type <> p.account_type;
        """).fetchall()

        if inconsistent_types:
            print(f"CẢNH BÁO: Phát hiện {len(inconsistent_types)} tài khoản lệch nhóm cha-con!")
        else:
            print("OK: 100% tài khoản con kế thừa đồng nhất nhóm tài khoản (account_type) từ cha.")

        # Kiểm tra tính toàn vẹn Materialized Path
        broken_paths = cur.execute("""
            SELECT c.account_code, c.path, p.path
            FROM accounts c
            JOIN accounts p ON p.id = c.parent_id
            WHERE c.path NOT LIKE p.path || c.account_code || '/';
        """).fetchall()

        if broken_paths:
            print(f"CẢNH BÁO: Phát hiện {len(broken_paths)} tài khoản có đường dẫn (path) bị sai lệch!")
        else:
            print("OK: 100% tài khoản có Materialized Path (/cha/con/) chính xác tuyệt đối.")

print("\nNạp Seed Data Thông tư 200 thành công!")
