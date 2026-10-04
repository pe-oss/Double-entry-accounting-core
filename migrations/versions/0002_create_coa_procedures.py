"""Create COA stored procedures: sp_create_account, sp_deactivate_account

Revision ID: 0002
Revises: 0001
Create Date: 2026-10-04

Mã lỗi (SQLSTATE) do các thủ tục phát ra:
    23505  unique_violation  -> trùng account_code
    AC400  dữ liệu đầu vào không hợp lệ
    AC404  không tìm thấy tài khoản
    AC409  vi phạm trạng thái nghiệp vụ (còn bút toán DRAFT, số dư khác 0)
"""
from alembic import op

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None

UPGRADE_SQL = r"""
-- =====================================================================
-- sp_create_account: tạo tài khoản, tự tính depth/path, chuyển cha thành tài khoản tổng hợp
-- =====================================================================
CREATE OR REPLACE PROCEDURE sp_create_account(
    p_account_code       VARCHAR,
    p_account_name       VARCHAR,
    p_account_type       VARCHAR,
    p_normal_balance     VARCHAR,
    p_parent_id          BIGINT,
    p_is_contra          BOOLEAN,
    p_description        TEXT,
    INOUT p_new_account_id BIGINT DEFAULT NULL
)
LANGUAGE plpgsql
AS $proc$
DECLARE
    v_code      VARCHAR := btrim(p_account_code);
    v_name      VARCHAR := btrim(p_account_name);
    v_type      VARCHAR := upper(btrim(p_account_type));
    v_balance   VARCHAR := upper(btrim(p_normal_balance));
    v_contra    BOOLEAN := COALESCE(p_is_contra, FALSE);
    v_expected  VARCHAR;
    v_parent    accounts;
    v_depth     INT := 1;
    v_path      VARCHAR;
    v_has_lines BOOLEAN := FALSE;
BEGIN
    -- 1. Kiểm tra đầu vào
    IF v_code IS NULL OR v_code = '' THEN
        RAISE EXCEPTION 'account_code không được để trống' USING ERRCODE = 'AC400';
    END IF;
    IF v_code !~ '^[A-Za-z0-9._-]+$' THEN
        RAISE EXCEPTION 'account_code "%" chỉ được chứa chữ, số, dấu chấm, gạch ngang, gạch dưới', v_code
            USING ERRCODE = 'AC400';
    END IF;
    IF v_name IS NULL OR v_name = '' THEN
        RAISE EXCEPTION 'account_name không được để trống' USING ERRCODE = 'AC400';
    END IF;
    IF v_type IS NULL OR v_type NOT IN ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE') THEN
        RAISE EXCEPTION 'account_type "%" không hợp lệ (ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE)', p_account_type
            USING ERRCODE = 'AC400';
    END IF;
    IF v_balance IS NULL OR v_balance NOT IN ('DEBIT', 'CREDIT') THEN
        RAISE EXCEPTION 'normal_balance "%" không hợp lệ (DEBIT, CREDIT)', p_normal_balance
            USING ERRCODE = 'AC400';
    END IF;

    -- Số dư thông thường phải khớp bản chất nhóm tài khoản (đảo chiều nếu là tài khoản điều chỉnh giảm)
    v_expected := CASE WHEN v_type IN ('ASSET', 'EXPENSE') THEN 'DEBIT' ELSE 'CREDIT' END;
    IF v_contra THEN
        v_expected := CASE v_expected WHEN 'DEBIT' THEN 'CREDIT' ELSE 'DEBIT' END;
    END IF;
    IF v_balance <> v_expected THEN
        RAISE EXCEPTION 'Tài khoản % (%, is_contra=%) phải có normal_balance = %',
            v_code, v_type, v_contra, v_expected USING ERRCODE = 'AC400';
    END IF;

    IF EXISTS (SELECT 1 FROM accounts WHERE account_code = v_code) THEN
        RAISE EXCEPTION 'Mã tài khoản "%" đã tồn tại', v_code USING ERRCODE = 'unique_violation';
    END IF;

    -- 2. Xử lý tài khoản cha (khóa dòng để tránh tạo đồng thời)
    IF p_parent_id IS NOT NULL THEN
        SELECT * INTO v_parent FROM accounts WHERE id = p_parent_id FOR UPDATE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Tài khoản cha id=% không tồn tại', p_parent_id USING ERRCODE = 'AC404';
        END IF;
        IF NOT v_parent.is_active THEN
            RAISE EXCEPTION 'Tài khoản cha % đã bị vô hiệu hóa', v_parent.account_code USING ERRCODE = 'AC409';
        END IF;
        IF v_parent.account_type <> v_type THEN
            RAISE EXCEPTION 'Tài khoản con (%) phải cùng nhóm với tài khoản cha % (%)',
                v_type, v_parent.account_code, v_parent.account_type USING ERRCODE = 'AC400';
        END IF;

        -- Tài khoản lá đã có bút toán thì không được biến thành tài khoản tổng hợp
        IF v_parent.is_leaf AND to_regclass('journal_entry_lines') IS NOT NULL THEN
            EXECUTE 'SELECT EXISTS (SELECT 1 FROM journal_entry_lines WHERE account_id = $1)'
                INTO v_has_lines USING v_parent.id;
            IF v_has_lines THEN
                RAISE EXCEPTION 'Tài khoản cha % đã phát sinh bút toán, không thể thêm tài khoản con',
                    v_parent.account_code USING ERRCODE = 'AC409';
            END IF;
        END IF;

        v_depth := v_parent.depth + 1;
        v_path  := v_parent.path || v_code || '/';
    ELSE
        v_path := '/' || v_code || '/';
    END IF;

    -- 3. Ghi tài khoản mới
    INSERT INTO accounts (account_code, account_name, account_type, normal_balance, parent_id,
                          is_leaf, is_contra, is_active, depth, path, description)
    VALUES (v_code, v_name, v_type, v_balance, p_parent_id,
            TRUE, v_contra, TRUE, v_depth, v_path, p_description)
    RETURNING id INTO p_new_account_id;

    -- 4. Cha trở thành tài khoản tổng hợp
    IF p_parent_id IS NOT NULL AND v_parent.is_leaf THEN
        UPDATE accounts SET is_leaf = FALSE WHERE id = p_parent_id;
    END IF;
END;
$proc$;

COMMENT ON PROCEDURE sp_create_account(VARCHAR, VARCHAR, VARCHAR, VARCHAR, BIGINT, BOOLEAN, TEXT, BIGINT) IS
    'Tạo tài khoản COA; tự tính depth, path và cập nhật is_leaf của tài khoản cha.';

-- =====================================================================
-- sp_deactivate_account: vô hiệu hóa tài khoản an toàn
-- =====================================================================
CREATE OR REPLACE PROCEDURE sp_deactivate_account(p_account_id BIGINT)
LANGUAGE plpgsql
AS $proc$
DECLARE
    v_acc         accounts;
    v_draft_count BIGINT := 0;
    v_balance     NUMERIC(18, 4) := 0;
BEGIN
    SELECT * INTO v_acc FROM accounts WHERE id = p_account_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tài khoản id=% không tồn tại', p_account_id USING ERRCODE = 'AC404';
    END IF;

    IF NOT v_acc.is_active THEN
        RAISE NOTICE 'Tài khoản % đã ở trạng thái vô hiệu hóa', v_acc.account_code;
        RETURN;
    END IF;

    -- Tài khoản tổng hợp chỉ được vô hiệu hóa khi mọi tài khoản con đã vô hiệu hóa
    IF EXISTS (SELECT 1 FROM accounts WHERE parent_id = v_acc.id AND is_active) THEN
        RAISE EXCEPTION 'Tài khoản % còn tài khoản con đang hoạt động', v_acc.account_code
            USING ERRCODE = 'AC409';
    END IF;

    -- Kiểm tra với Sổ cái (chỉ khi các bảng sổ cái đã tồn tại)
    IF to_regclass('journal_entries') IS NOT NULL AND to_regclass('journal_entry_lines') IS NOT NULL THEN
        -- a. Không còn bút toán DRAFT dùng tài khoản này (hoặc tài khoản con)
        EXECUTE $q$
            SELECT COUNT(DISTINCT je.id)
            FROM journal_entries je
            JOIN journal_entry_lines jl ON jl.journal_entry_id = je.id
            JOIN accounts a ON a.id = jl.account_id
            WHERE je.status = 'DRAFT' AND starts_with(a.path, $1)
        $q$ INTO v_draft_count USING v_acc.path;
        IF v_draft_count > 0 THEN
            RAISE EXCEPTION 'Tài khoản % đang được dùng trong % bút toán DRAFT', v_acc.account_code, v_draft_count
                USING ERRCODE = 'AC409';
        END IF;

        -- b. Số dư thực tế (từ bút toán POSTED) phải bằng 0
        EXECUTE $q$
            SELECT COALESCE(SUM(jl.debit_amount - jl.credit_amount), 0)
            FROM journal_entries je
            JOIN journal_entry_lines jl ON jl.journal_entry_id = je.id
            JOIN accounts a ON a.id = jl.account_id
            WHERE je.status = 'POSTED' AND starts_with(a.path, $1)
        $q$ INTO v_balance USING v_acc.path;
        IF v_balance <> 0 THEN
            RAISE EXCEPTION 'Tài khoản % còn số dư % (phải bằng 0 mới được vô hiệu hóa)', v_acc.account_code, v_balance
                USING ERRCODE = 'AC409';
        END IF;
    END IF;

    UPDATE accounts SET is_active = FALSE WHERE id = v_acc.id;
END;
$proc$;

COMMENT ON PROCEDURE sp_deactivate_account(BIGINT) IS
    'Vô hiệu hóa tài khoản khi không còn bút toán DRAFT, số dư = 0 và không còn tài khoản con hoạt động.';
"""

DOWNGRADE_SQL = """
DROP PROCEDURE IF EXISTS sp_deactivate_account(BIGINT);
DROP PROCEDURE IF EXISTS sp_create_account(VARCHAR, VARCHAR, VARCHAR, VARCHAR, BIGINT, BOOLEAN, TEXT, BIGINT);
"""


def upgrade() -> None:
    raw_conn = op.get_bind().connection.dbapi_connection
    with raw_conn.cursor() as cur:
        cur.execute(UPGRADE_SQL)


def downgrade() -> None:
    raw_conn = op.get_bind().connection.dbapi_connection
    with raw_conn.cursor() as cur:
        cur.execute(DOWNGRADE_SQL)
