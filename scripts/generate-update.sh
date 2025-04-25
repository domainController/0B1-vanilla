#!/usr/bin/env bash
# script: group-updates.sh
# description: Génère un snippet HTML groupé par date, un seul header par jour, écrit dans public/updates-snippet.html
# usage: ./scripts/group-updates.sh [days]

# Répertoire du dépôt
REPO_DIR="$HOME/Documents/OB1Vanilla"
# Fichier de sortie
OUTPUT_SNIPPET="$REPO_DIR/public/updates-snippet.html"
# Nombre de jours en arrière (par défaut 5)
DAYS=${1:-5}

# Se positionner dans le dépôt
cd "$REPO_DIR" || { echo "Erreur: impossible d'accéder à $REPO_DIR"; exit 1; }

# Prépare le fichier de sortie
{
  echo '<!-- START UPDATES SNIPPET -->'
  echo '<div class="legal-container">'
} > "$OUTPUT_SNIPPET"

# Récupère les dates uniques des derniers commits
dates=( $(git log --since="$DAYS days ago" --date=format:'%Y-%m-%d|%A %d %B %Y – %H:%M:%S' --pretty=format:'%ad' | cut -d'|' -f1 | sort -u -r) )

# Pour chaque date, regroupe les commits
for iso in "${dates[@]}"; do
  # Récupérer la date lisible (première occurrence)
  full_date=$(git log --since="$iso 00:00" --until="$iso 23:59" --date=format:'%Y-%m-%d|%A %d %B %Y – %H:%M:%S' --pretty=format:'%ad' | head -n1 | cut -d'|' -f2)
  # Choix de l'icône (utilise UPDATE par défaut)
  icon="🔄"
  # En-tête unique pour ce jour
  echo "  <h2>${icon} ${full_date}</h2>" >> "$OUTPUT_SNIPPET"
  echo "  <ul>" >> "$OUTPUT_SNIPPET"
  # Lister les messages de commit pour ce jour
  git log --since="$iso 00:00" --until="$iso 23:59" --pretty=format:'    <li>%s</li>' >> "$OUTPUT_SNIPPET"
  echo "  </ul>" >> "$OUTPUT_SNIPPET"
  echo >> "$OUTPUT_SNIPPET"
done

# Statistiques pour le jour le plus récent
latest_iso=${dates[0]}
count_commits=$(git log --since="$latest_iso 00:00" --until="$latest_iso 23:59" --oneline | wc -l)
count_pages=$(git log --since="$latest_iso 00:00" --name-only --pretty=format:"" | grep '\.html$' | sort -u | wc -l)

# Ajoute la stat en bas
printf '  <p>📊 Today: %d commits across %d pages modified.</p>\n' "$count_commits" "$count_pages" >> "$OUTPUT_SNIPPET"
printf '</div>\n<!-- END UPDATES SNIPPET -->\n' >> "$OUTPUT_SNIPPET"

# Affichage final
echo "Snippet généré dans $OUTPUT_SNIPPET"
