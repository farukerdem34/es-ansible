#!/bin/bash

TEMPLATE_DIR="/opt/ctf/templates"
CTF_ROOT="/opt/ctf"

template_folders=($(find "$TEMPLATE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))

team_folders=($(find "$CTF_ROOT" -mindepth 1 -maxdepth 1 -type d -name "team*"))

for team_path in "${team_folders[@]}"; do
  echo "Processing team folder: $team_path"

  for tmpl in "${template_folders[@]}"; do
    target_dir="$team_path/$tmpl"
    source_dir="$TEMPLATE_DIR/$tmpl"

    mkdir -p "$target_dir"

    for file in "$source_dir"/*; do
      [ -f "$file" ] || continue # Sadece dosyalarla ilgilen

      filename=$(basename "$file")
      link_target="$target_dir/$filename"

      if [ ! -e "$link_target" ]; then
        ln -s "$file" "$link_target"
        echo "Linked: $link_target -> $file"
      else
        echo "Exists: $link_target (skipped)"
      fi
    done
  done
done
