#!/bin/bash
#
# script: generate-update.sh
# description: Generates update.html and updates timestamps on HTML pages from recent Git commits.
# usage: ./scripts/generate-update.sh
# output: 
#   - ./CHANGELOG.md         (updates changelog file)
#   - ./public/updates.html  (HTML updates page for the site)
#   - Timestamp injection    (bottom-right on all HTML pages in /public)
# tags: update, changelog, html, automation, bash, timestamp
# author: Patrice / AfterShift Project
# version: 2.0 (2025-04-25)
#

# === CONFIGURATION ===
REPO_DIR="."                              # Racine de ton dépôt
PUBLIC_DIR="./public"                     # Répertoire pour updates.html
CHANGELOG_FILE="public/CHANGELOG.md"            # Chemin du changelog
UPDATE_HTML_FILE="public/updates.html" # Chemin du fichier update HTML
MAIN_BRANCH="main"                         # Branche principale (adapter si besoin)
TIMEZONE="Europe/Stockholm"                # Fuseau horaire correct
DATE_FORMAT="%A %d %B %Y à %H:%M:%S"        # Format lisible de date

# === FONCTIONS ===

## Fonction 1 : Formater une date proprement
format_date() {
  date -u +"$DATE_FORMAT"
}

## Fonction 2 : Générer une entrée pour le changelog
generate_changelog_entry() {
  local message="$1"
  local timestamp="$(format_date)"
  echo "- **$timestamp** : $message"
}

## Fonction 3 : Générer un updates.html à partir du changelog
generate_update_html() {
  echo "<div class=\"legal-container\">" > "$UPDATE_HTML_FILE"
  echo "<h1>Latest Updates</h1>" >> "$UPDATE_HTML_FILE"
  markdown_to_html "$CHANGELOG_FILE" >> "$UPDATE_HTML_FILE"
  echo "</div>" >> "$UPDATE_HTML_FILE"
}

## Fonction 4 : Convertir Markdown en HTML simple
markdown_to_html() {
  sed -e 's/^# \(.*\)$/<h1>\1<\/h1>/' \
      -e 's/^## \(.*\)$/<h2>\1<\/h2>/' \
      -e 's/^- \*\*\(.*\)\*\* : \(.*\)$/<p><strong>\1<\/strong> — \2<\/p>/' \
      "$1"
}

## Fonction 5 : Ajouter un timestamp en bas de chaque fichier HTML modifié
add_timestamp_to_html_files() {
  local updated_date="$(format_date)"
  find "$PUBLIC_DIR" -name "*.html" | while read -r file; do
    if grep -q '</body>' "$file"; then
      sed -i '' "/<\/body>/i\\
<div class='page-timestamp'>Updated at $updated_date</div>
" "$file"
    fi
  done
}

## Fonction 6 : Générer une stat de journée
generate_daily_stat() {
  local commit_count=$(git rev-list --count HEAD)
  local file_count=$(git diff --name-only "$MAIN_BRANCH"...HEAD | wc -l)
  echo "Aujourd'hui : $commit_count commits sur $file_count fichiers modifiés."
}

# === MAIN EXECUTION ===

echo "🛠️ Generating Changelog and Updates..."

# 1. Extraire les commits récents
git log --since="1 day ago" --pretty=format:"%s" > commit_messages.tmp

# 2. Ajouter au changelog
while read -r message; do
  generate_changelog_entry "$message" >> "$CHANGELOG_FILE"
done < commit_messages.tmp

# 3. Générer updates.html
generate_update_html

# 4. Mettre à jour timestamps sur toutes les pages
add_timestamp_to_html_files

# 5. Générer la stat de la journée
generate_daily_stat >> "$CHANGELOG_FILE"

# Nettoyage
rm commit_messages.tmp

echo "✅ Updates generated successfully!"