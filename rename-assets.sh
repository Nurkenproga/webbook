#!/bin/bash
# Переименовывает файлы в src/assets: "1 normal.JPG" → "1-normal.jpg", "1 loveised.png" → "1-loveised.png"
# Запуск: из папки year/latest выполни: bash rename-assets.sh

cd "$(dirname "$0")/src/assets" || exit 1

for f in *normal*; do
  [ -f "$f" ] || continue
  num=$(echo "$f" | grep -oE '^[0-9]+')
  ext=$(echo "$f" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]')
  [ -n "$num" ] && mv "$f" "${num}-normal.${ext}" 2>/dev/null && echo "  $f → ${num}-normal.${ext}"
done

for f in *loveised*; do
  [ -f "$f" ] || continue
  num=$(echo "$f" | grep -oE '^[0-9]+')
  [ -n "$num" ] && mv "$f" "${num}-loveised.png" 2>/dev/null && echo "  $f → ${num}-loveised.png"
done

echo "Готово. Перезапусти npm run dev"
