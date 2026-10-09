#!/usr/bin/env bash
# Pipeline de exportación: genera un binario por cada SO soportado.
# Uso: tools/export_all.sh [preset ...]   (sin args = todos)
# Requisitos: export templates de Godot instalados.
#   - Linux / Windows / macOS / Web: solo templates.
#   - Android: Android SDK + JDK configurados en el editor.
#   - iOS: macOS + Xcode (no se puede construir en Linux).

set -u

GODOT="${GODOT:-godot}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

presets=("Linux" "Windows Desktop" "macOS" "Web" "Android" "iOS")
declare -A OUT=(
  ["Linux"]="build/linux/AncletoAdventure.x86_64"
  ["Windows Desktop"]="build/windows/AncletoAdventure.exe"
  ["macOS"]="build/macos/AncletoAdventure.zip"
  ["Web"]="build/web/index.html"
  ["Android"]="build/android/AncletoAdventure.apk"
  ["iOS"]="build/ios/AncletoAdventure.ipa"
)

if [ "$#" -gt 0 ]; then presets=("$@"); fi

ok=0; fail=0
for preset in "${presets[@]}"; do
  out="${OUT[$preset]:-}"
  if [ -z "$out" ]; then echo "Preset desconocido: $preset"; fail=$((fail+1)); continue; fi
  mkdir -p "$(dirname "$out")"
  log="$(mktemp)"
  echo "=== Exportando '$preset' -> $out ==="
  if "$GODOT" --headless --export-release "$preset" "$out" >"$log" 2>&1 && [ -f "$out" ]; then
    echo "  OK ($(du -h "$out" | cut -f1))"; ok=$((ok+1))
  else
    echo "  FALLÓ:"; tail -3 "$log" | sed 's/^/    /'; fail=$((fail+1))
  fi
  rm -f "$log"
done

echo "=== Resumen: $ok OK, $fail fallidos ==="
