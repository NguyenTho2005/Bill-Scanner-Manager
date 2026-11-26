#!/usr/bin/env bash
# =============================================================================
# BillTracker — Demo launcher
# Chạy 1 lệnh: bật backend (Docker) + migrate + seed + emulator + app Flutter
#
#   ./demo.sh                  # chạy tất cả
#   ./demo.sh --app-only       # chỉ chạy app (không cần backend)
#   ./demo.sh --backend-only   # chỉ chạy backend
#   ./demo.sh --release        # chạy app bản release
#   ./demo.sh --device <id>    # chỉ định thiết bị/emulator
#   ./demo.sh --no-build       # không rebuild Docker image
#   ./demo.sh --avd <name>     # đổi emulator (mặc định Pixel_6)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Tự nhận diện cấu trúc repo ────────────────────────────────────────────────
# Layout A (repo gốc):  ./bill_tracker/  + ./backend/
# Layout B (repo app):  ./ (pubspec.yaml) + ./backend/
if [[ -f "$SCRIPT_DIR/bill_tracker/pubspec.yaml" ]]; then
  APP_DIR="$SCRIPT_DIR/bill_tracker"
  BACKEND_DIR="$SCRIPT_DIR/backend"
elif [[ -f "$SCRIPT_DIR/pubspec.yaml" ]]; then
  APP_DIR="$SCRIPT_DIR"
  BACKEND_DIR="$SCRIPT_DIR/backend"
else
  echo "❌ Không tìm thấy app Flutter (pubspec.yaml). Chạy script trong thư mục dự án."
  exit 1
fi

# ── Tham số ──────────────────────────────────────────────────────────────────
RUN_BACKEND=1
RUN_APP=1
DO_BUILD=1
RELEASE=0
DEVICE="${DEVICE:-}"
AVD="${AVD_NAME:-Pixel_6}"

usage() {
  sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-only)     RUN_BACKEND=0 ;;
    --backend-only) RUN_APP=0 ;;
    --no-build)     DO_BUILD=0 ;;
    --release)      RELEASE=1 ;;
    --device)       DEVICE="${2:-}"; shift ;;
    --avd)          AVD="${2:-}"; shift ;;
    -h|--help)      usage; exit 0 ;;
    *) echo "❌ Tham số không hợp lệ: $1"; usage; exit 1 ;;
  esac
  shift
done

# ── Môi trường ───────────────────────────────────────────────────────────────
export PATH="$HOME/development/flutter/bin:$HOME/Android/Sdk/platform-tools:$HOME/Android/Sdk/emulator:$PATH"

ADB="$(command -v adb || true)"
if [[ -x "$HOME/Android/Sdk/platform-tools/adb" ]]; then
  ADB="$HOME/Android/Sdk/platform-tools/adb"
fi

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "⚠️  Đang chạy bằng root — Flutter sẽ cảnh báo."
  # /root có thể bị hạn chế; dùng home của user sở hữu project (mặc định /home/tho)
  if [[ -d "${BILLTRACKER_HOME:-/home/tho}" ]]; then
    export HOME="${BILLTRACKER_HOME:-/home/tho}"
    export GRADLE_USER_HOME="$HOME/.gradle"
    export ANDROID_USER_HOME="$HOME/.android"
    export ANDROID_SDK_HOME="$HOME"
    echo "   Dùng HOME=$HOME cho Gradle/Android."
  fi
fi

echo "============================================================"
echo " BillTracker Demo Launcher"
echo " App:     $APP_DIR"
echo " Backend: $BACKEND_DIR"
echo "============================================================"

# ── 1. Backend ───────────────────────────────────────────────────────────────
if [[ $RUN_BACKEND -eq 1 ]]; then
  echo ""
  echo "▶ [1/3] Khởi động backend (API + PostgreSQL + MinIO)..."

  if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker chưa chạy hoặc user không có quyền. Mở Docker rồi thử lại."
    exit 1
  fi

  cd "$BACKEND_DIR"
  [[ -f .env ]] || cp .env.example .env

  if [[ $DO_BUILD -eq 1 ]]; then
    docker compose up -d --build
  else
    docker compose up -d
  fi

  echo "   ⏳ Chờ API sẵn sàng..."
  READY=0
  for _ in $(seq 1 60); do
    if curl -fsS http://localhost:8000/health/ready >/dev/null 2>&1; then
      READY=1
      break
    fi
    sleep 2
  done

  if [[ $READY -ne 1 ]]; then
    echo "❌ Backend không sẵn sàng sau 120s. Log gần nhất:"
    docker compose logs --tail=50 api || true
    exit 1
  fi

  echo "   ▶ Chạy migration..."
  docker compose exec -T api alembic upgrade head

  echo "   ▶ Seed dữ liệu dev (idempotent)..."
  docker compose exec -T api python scripts/seed_dev.py

  echo "   ✅ Backend OK:"
  echo "      API:    http://localhost:8000"
  echo "      Docs:   http://localhost:8000/docs"
  echo "      MinIO:  http://localhost:9001  (minioadmin / minioadmin)"
fi

# ── 2. App Flutter ───────────────────────────────────────────────────────────
if [[ $RUN_APP -eq 1 ]]; then
  echo ""
  echo "▶ [2/3] Chuẩn bị app Flutter..."

  if ! command -v flutter >/dev/null 2>&1; then
    echo "❌ Không tìm thấy flutter trong PATH."
    exit 1
  fi

  cd "$APP_DIR"
  flutter pub get

  if [[ -z "$DEVICE" && -n "$ADB" ]]; then
    DEVICE="$("$ADB" devices | awk 'NR>1 && $2=="device" {print $1; exit}')"
  fi

  if [[ -z "$DEVICE" ]]; then
    echo "   ▶ Bật emulator '$AVD'..."
    flutter emulators --launch "$AVD" >/dev/null 2>&1 || true

    echo "   ⏳ Chờ emulator khởi động..."
    for _ in $(seq 1 120); do
      if [[ -n "$ADB" ]]; then
        DEVICE="$("$ADB" devices | awk 'NR>1 && $2=="device" {print $1; exit}')"
      fi
      [[ -n "$DEVICE" ]] && break
      sleep 2
    done

    if [[ -z "$DEVICE" ]]; then
      echo "❌ Không thấy thiết bị Android. Bật emulator thủ công rồi chạy lại:"
      echo "   flutter emulators --launch $AVD"
      exit 1
    fi
  fi

  echo "   ⏳ Chờ Android boot xong ($DEVICE)..."
  for _ in $(seq 1 60); do
    BOOT="$("$ADB" -s "$DEVICE" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
    [[ "$BOOT" == "1" ]] && break
    sleep 2
  done

  echo ""
  echo "▶ [3/3] Chạy app trên $DEVICE..."
  echo "   (Ctrl+C để dừng app — backend vẫn chạy)"
  echo ""

  RUN_ARGS=()
  [[ $RELEASE -eq 1 ]] && RUN_ARGS+=(--release)

  flutter run -d "$DEVICE" "${RUN_ARGS[@]}"
fi

echo ""
echo "✅ Backend đang chạy. Tắt bằng: cd \"$BACKEND_DIR\" && make down"
