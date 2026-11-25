#!/usr/bin/env python3
"""Export OpenAPI schema to docs/openapi.json."""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from app.main import create_app


def export_openapi() -> None:
    app = create_app()
    schema = app.openapi()

    output_path = Path(__file__).parent.parent / "docs" / "openapi.json"
    output_path.parent.mkdir(exist_ok=True)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(schema, f, indent=2, ensure_ascii=False)

    print(f"✅ OpenAPI schema exported to {output_path}")
    print(f"   Endpoints: {len(schema.get('paths', {}))}")
    print(f"   Schemas: {len(schema.get('components', {}).get('schemas', {}))}")


if __name__ == "__main__":
    export_openapi()
