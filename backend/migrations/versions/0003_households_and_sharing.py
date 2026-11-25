"""households and shared budgets/transactions

Revision ID: 0003
Revises: 0002
Create Date: 2026-11-25 00:00:00.000000

"""

import sqlalchemy as sa
from alembic import op

revision = "0003"
down_revision = "0002"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "households",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("created_by", sa.String(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["created_by"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "household_members",
        sa.Column("household_id", sa.String(), nullable=False),
        sa.Column("user_id", sa.String(), nullable=False),
        sa.Column("role", sa.String(), nullable=False),
        sa.Column("display_name", sa.String(), nullable=True),
        sa.Column("joined_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["household_id"], ["households.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("household_id", "user_id"),
    )
    op.create_index("ix_household_members_user_id", "household_members", ["user_id"])

    op.create_table(
        "household_invites",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("household_id", sa.String(), nullable=False),
        sa.Column("code", sa.String(), nullable=False),
        sa.Column("created_by", sa.String(), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("accepted_by", sa.String(), nullable=True),
        sa.Column("accepted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["created_by"], ["users.id"]),
        sa.ForeignKeyConstraint(["accepted_by"], ["users.id"]),
        sa.ForeignKeyConstraint(["household_id"], ["households.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("code"),
    )
    op.create_index("ix_household_invites_household_id", "household_invites", ["household_id"])
    op.create_index("ix_household_invites_code", "household_invites", ["code"])

    op.add_column("budgets", sa.Column("household_id", sa.String(), nullable=True))
    op.create_foreign_key(
        "fk_budgets_household_id", "budgets", "households", ["household_id"], ["id"]
    )
    op.create_index("ix_budgets_household_id", "budgets", ["household_id"])

    op.add_column("transactions", sa.Column("household_id", sa.String(), nullable=True))
    op.add_column(
        "transactions",
        sa.Column("is_shared", sa.Boolean(), nullable=False, server_default=sa.false()),
    )
    op.create_foreign_key(
        "fk_transactions_household_id", "transactions", "households", ["household_id"], ["id"]
    )
    op.create_index("ix_transactions_household_id", "transactions", ["household_id"])

    op.add_column("change_log", sa.Column("household_id", sa.String(), nullable=True))
    op.create_index("ix_change_log_household_id", "change_log", ["household_id"])


def downgrade() -> None:
    op.drop_index("ix_change_log_household_id", table_name="change_log")
    op.drop_column("change_log", "household_id")

    op.drop_index("ix_transactions_household_id", table_name="transactions")
    op.drop_constraint("fk_transactions_household_id", "transactions", type_="foreignkey")
    op.drop_column("transactions", "is_shared")
    op.drop_column("transactions", "household_id")

    op.drop_index("ix_budgets_household_id", table_name="budgets")
    op.drop_constraint("fk_budgets_household_id", "budgets", type_="foreignkey")
    op.drop_column("budgets", "household_id")

    op.drop_index("ix_household_invites_code", table_name="household_invites")
    op.drop_index("ix_household_invites_household_id", table_name="household_invites")
    op.drop_table("household_invites")

    op.drop_index("ix_household_members_user_id", table_name="household_members")
    op.drop_table("household_members")

    op.drop_table("households")
