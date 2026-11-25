.PHONY: help up down build migrate migrate-down seed test test-unit test-integration lint format typecheck openapi clean

# ── Variables ──────────────────────────────────────────────────────────────────
COMPOSE = docker compose
PYTHON = python3.12
PIP = pip
API_URL = http://localhost:8000

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ── Docker Compose ────────────────────────────────────────────────────────────
up: ## Start all services (API + PostgreSQL + MinIO)
	$(COMPOSE) up --build

up-detached: ## Start all services in background
	$(COMPOSE) up --build -d
	@echo "Services started. API: $(API_URL)"
	@echo "MinIO Console: http://localhost:9001 (user: minioadmin, pass: minioadmin)"

down: ## Stop all services
	$(COMPOSE) down

down-clean: ## Stop all services and remove volumes
	$(COMPOSE) down -v

build: ## Build Docker image
	$(COMPOSE) build

logs: ## Follow API logs
	$(COMPOSE) logs -f api

# ── Database Migrations ───────────────────────────────────────────────────────
migrate: ## Run all pending Alembic migrations
	$(COMPOSE) exec api alembic upgrade head

migrate-down: ## Rollback last Alembic migration
	$(COMPOSE) exec api alembic downgrade -1

migrate-reset: ## Drop all tables and re-run migrations (DESTRUCTIVE)
	$(COMPOSE) exec api alembic downgrade base
	$(COMPOSE) exec api alembic upgrade head

migrate-history: ## Show migration history
	$(COMPOSE) exec api alembic history --verbose

migrate-current: ## Show current migration version
	$(COMPOSE) exec api alembic current

# ── Local Development (without Docker) ───────────────────────────────────────
install: ## Install dependencies locally
	$(PIP) install -e ".[dev]"

migrate-local: ## Run migrations locally (requires .env)
	alembic upgrade head

seed: ## Seed development data (idempotent)
	$(COMPOSE) exec api python scripts/seed_dev.py

seed-local: ## Seed development data locally
	python scripts/seed_dev.py

# ── Testing ───────────────────────────────────────────────────────────────────
test: ## Run all tests
	pytest -v --tb=short --cov=app --cov-report=term-missing

test-unit: ## Run unit tests only
	pytest tests/unit/ -v

test-integration: ## Run integration tests only
	pytest tests/integration/ -v

test-pg: ## Run PostgreSQL-compatible tests against docker-compose postgres-test
	$(COMPOSE) --profile test up -d postgres-test --wait
	TEST_DATABASE_URL="postgresql+asyncpg://billtracker:billtracker_dev@localhost:5433/billtracker_test" \
	pytest tests/integration/test_postgres_types.py tests/integration/test_households.py tests/integration/test_sync_push.py -v

test-security: ## Run IDOR and security tests
	pytest tests/integration/test_idor.py tests/integration/test_auth.py -v

test-sync: ## Run sync-specific tests
	pytest tests/integration/test_sync_push.py tests/integration/test_sync_pull.py \
	       tests/integration/test_sync_two_devices.py tests/integration/test_sync_bootstrap.py -v

test-ci: ## Run tests in CI mode (no color, with coverage)
	pytest --tb=short --cov=app --cov-report=xml --no-header -q

# ── Code Quality ──────────────────────────────────────────────────────────────
lint: ## Run ruff linter
	ruff check app/ tests/ scripts/

lint-fix: ## Run ruff linter with auto-fix
	ruff check --fix app/ tests/ scripts/

format: ## Run ruff formatter
	ruff format app/ tests/ scripts/

format-check: ## Check formatting without changes
	ruff format --check app/ tests/ scripts/

typecheck: ## Run mypy type checker
	mypy app/

check: lint format-check typecheck ## Run all checks

# ── API Documentation ─────────────────────────────────────────────────────────
openapi: ## Export OpenAPI schema to docs/openapi.json
	python scripts/export_openapi.py

docs-serve: ## Open API docs in browser
	@echo "API docs: $(API_URL)/docs"
	@echo "ReDoc: $(API_URL)/redoc"

# ── Utilities ─────────────────────────────────────────────────────────────────
shell: ## Open Python shell in API container
	$(COMPOSE) exec api python

psql: ## Open PostgreSQL shell
	$(COMPOSE) exec postgres psql -U billtracker -d billtracker

minio-console: ## Open MinIO console URL
	@echo "MinIO Console: http://localhost:9001"
	@echo "Username: minioadmin, Password: minioadmin"

clean: ## Remove Python cache files
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name ".coverage" -delete
	rm -rf .mypy_cache .ruff_cache .pytest_cache htmlcov

health: ## Check API health
	curl -s $(API_URL)/health | python -m json.tool

health-ready: ## Check API readiness (DB + S3)
	curl -s $(API_URL)/health/ready | python -m json.tool
