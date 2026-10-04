"""Create accounts table (Chart of Accounts - Phân hệ 1)

Revision ID: 0001
Revises:
Create Date: 2026-10-04
"""
from alembic import op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(
        """
        CREATE TABLE accounts (
            id              BIGSERIAL PRIMARY KEY,
            account_code    VARCHAR(50)  NOT NULL UNIQUE,
            account_name    VARCHAR(255) NOT NULL,
            account_type    VARCHAR(20)  NOT NULL
                CONSTRAINT chk_accounts_type
                CHECK (account_type IN ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE')),
            normal_balance  VARCHAR(10)  NOT NULL
                CONSTRAINT chk_accounts_normal_balance
                CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
            parent_id       BIGINT NULL REFERENCES accounts(id),
            is_leaf         BOOLEAN NOT NULL DEFAULT TRUE,
            is_contra       BOOLEAN NOT NULL DEFAULT FALSE,
            is_active       BOOLEAN NOT NULL DEFAULT TRUE,
            depth           INT NOT NULL DEFAULT 1
                CONSTRAINT chk_accounts_depth CHECK (depth >= 1),
            path            VARCHAR(500) NOT NULL,
            description     TEXT NULL,
            created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            -- Mã tài khoản là một đoạn trong path nên không được chứa '/' hoặc khoảng trắng
            CONSTRAINT chk_accounts_code_format CHECK (account_code ~ '^[A-Za-z0-9._-]+$'),
            CONSTRAINT chk_accounts_not_self_parent CHECK (parent_id IS NULL OR parent_id <> id),
            -- Tài khoản gốc ở depth 1, tài khoản con ở depth > 1
            CONSTRAINT chk_accounts_root_depth CHECK ((parent_id IS NULL) = (depth = 1))
        );

        COMMENT ON TABLE accounts IS
            'Hệ thống tài khoản (COA). Adjacency List (parent_id) + Materialized Path (path). Không lưu số dư.';
        COMMENT ON COLUMN accounts.is_leaf IS 'TRUE: tài khoản chi tiết được hạch toán; FALSE: tài khoản mẹ tổng hợp';
        COMMENT ON COLUMN accounts.is_contra IS 'TRUE: tài khoản điều chỉnh giảm (vd 214, 521)';
        COMMENT ON COLUMN accounts.path IS 'Đường dẫn phả hệ, vd /111/1111/';

        CREATE INDEX idx_accounts_parent_id ON accounts(parent_id);
        CREATE INDEX idx_accounts_path ON accounts(path);
        CREATE INDEX idx_accounts_type_leaf ON accounts(account_type, is_leaf);

        -- Tự động cập nhật updated_at
        CREATE OR REPLACE FUNCTION fn_set_updated_at() RETURNS trigger
        LANGUAGE plpgsql AS $$
        BEGIN
            NEW.updated_at := CURRENT_TIMESTAMP;
            RETURN NEW;
        END;
        $$;

        CREATE TRIGGER trg_accounts_updated_at
            BEFORE UPDATE ON accounts
            FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
        """
    )


def downgrade() -> None:
    op.execute(
        """
        DROP TABLE IF EXISTS accounts;
        DROP FUNCTION IF EXISTS fn_set_updated_at();
        """
    )
