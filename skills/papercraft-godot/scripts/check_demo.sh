#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
demo_dir="$skill_dir/assets/demo"
godot_bin="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
output_path="${PAPERCRAFT_CAPTURE:-${TMPDIR:-/tmp}/papercraft-godot-demo.png}"

if [[ ! -x "$godot_bin" ]]; then
  echo "Godot not found at $godot_bin" >&2
  echo "Set GODOT_BIN to the Godot 4 executable." >&2
  exit 1
fi

echo "Godot: $("$godot_bin" --version)"
"$godot_bin" --headless --path "$demo_dir" -- --smoke
"$godot_bin" --path "$demo_dir" --audio-driver Dummy --position 0,0 -- --capture="$output_path"

if [[ ! -s "$output_path" ]]; then
  echo "Expected capture was not created: $output_path" >&2
  exit 1
fi

echo "Demo verified:"
echo "  capture: $output_path"
echo "  launch:  $godot_bin --path $demo_dir"
