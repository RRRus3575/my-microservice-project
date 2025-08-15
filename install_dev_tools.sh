set -e


echo ""
echo "=== Перевірка apt-get ==="
if ! command -v apt-get >/dev/null 2>&1; then
  echo "Помилка: потрібен apt-get (Ubuntu/Debian)"
  exit 1
fi

echo ""
echo "=== Оновлення списку пакетів ==="
sudo apt-get update -y

echo ""
echo "=== Встановлення Docker ==="
if command -v docker >/dev/null 2>&1; then
  docker --version
  echo "Docker вже встановлено"
else
  sudo apt-get install -y docker.io
  # Увімкнути сервіс (де доступно)
  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable docker || true
    sudo systemctl start docker || true
  fi

  if getent group docker >/dev/null; then
    sudo usermod -aG docker "$USER" || true
    echo "Користувача додано до групи docker"
  fi
  docker --version || true
fi

echo ""
echo "=== Встановлення Docker Compose ==="
if docker compose version >/dev/null 2>&1; then
  docker compose version | head -n1
  echo "Docker Compose вже встановлено"
else
  sudo apt-get install -y docker-compose-plugin
  docker compose version || true
fi

echo ""
echo "=== Встановлення Python 3, pip та venv ==="
sudo apt-get install -y python3 python3-pip python3-venv

echo ""
echo "=== Перевірка версії Python ==="
PY_OK=0
python3 - <<'PY' && PY_OK=1 || true
import sys
print("Знайдено Python:", sys.version.split()[0])
raise SystemExit(0 if sys.version_info >= (3,9) else 1)
PY
if [ "$PY_OK" -ne 1 ]; then
  echo "Увага: версія Python нижче 3.9. Спробуйте оновити систему або поставити новішу версію"
fi

echo ""
echo "=== Встановлення Django через pip у віртуальне середовище ==="
VENV_DIR="$HOME/.venvs/devtools"
if [ ! -d "$VENV_DIR" ]; then
  mkdir -p "$HOME/.venvs"
  python3 -m venv "$VENV_DIR"
fi


. "$VENV_DIR/bin/activate"

pip install --upgrade pip
pip install "Django>=4.2"

echo ""
echo "=== Перевірка встановлення Django ==="
django-admin --version || true
python -c "import django; print('django:', django.get_version())" || true

echo ""
echo "Готово"
echo "Щоб користуватись Django з терміналу:"
echo "  source \"$VENV_DIR/bin/activate\""
echo "або викликайте повний шлях:"
echo "  $VENV_DIR/bin/django-admin startproject myproj"
