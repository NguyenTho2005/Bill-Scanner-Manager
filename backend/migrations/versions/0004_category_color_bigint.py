"""category color_value as BIGINT (ARGB colors exceed int32)

Revision ID: 0004
Revises: 0003
Create Date: 2026-11-25 20:40:00.000000

"""

import sqlalchemy as sa
from alembic import op

revision = "0004"
down_revision = "0003"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.alter_column(
        "categories",
        "color_value",
        existing_type=sa.Integer(),
        type_=sa.BigInteger(),
        existing_nullable=False,
    )


def downgrade() -> None:
    op.alter_column(
        "categories",
        "color_value",
        existing_type=sa.BigInteger(),
        type_=sa.Integer(),
        existing_nullable=False,
    )
