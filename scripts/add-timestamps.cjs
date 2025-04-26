// add-timestamps.cjs
// Ce script insère ou met à jour automatiquement un timestamp dans un fichier index.html
// Seulement si le fichier a été modifié récemment.

// Importation des modules Node.js nécessaires
const fs = require("fs");
const path = require("path");

// Définir le chemin du fichier à modifier
const filePath = path.join(__dirname, "..", "index.html");

// Lire les métadonnées du fichier pour obtenir la date de dernière modification
const stats = fs.statSync(filePath);
const lastModified = stats.mtime;

// Lire le contenu actuel du fichier
let content = fs.readFileSync(filePath, "utf8");

// Définir où on veut insérer ou mettre à jour le timestamp
const timestampMarker = "<!-- TIMESTAMP -->";

// Créer un nouveau timestamp lisible
const now = new Date();
const timestampText = `<small>Last updated: ${now.toLocaleString("en-GB", {
  dateStyle: "full",
  timeStyle: "short",
})}</small class="timestamp">`;

// Fonction principale : met à jour ou insère le timestamp
function updateTimestamp() {
  // Vérifier si le fichier contient déjà le marqueur
  if (content.includes(timestampMarker)) {
    console.log("Marqueur TIMESTAMP trouvé, mise à jour du timestamp...");
    content = content.replace(timestampMarker, timestampText);
  } else {
    console.log(
      "Aucun marqueur trouvé. Insertion du timestamp après le premier <h1>..."
    );
    // Si aucun marqueur, tenter d'injecter après la première balise <h1>
    const h1EndIndex = content.indexOf("</h1>");
    if (h1EndIndex !== -1) {
      content =
        content.slice(0, h1EndIndex + 5) +
        "\n" +
        timestampText +
        content.slice(h1EndIndex + 5);
    } else {
      console.log(
        "Erreur : aucun <h1> trouvé, impossible d'insérer le timestamp proprement."
      );
      return;
    }
  }

  // Réécriture du fichier mis à jour
  fs.writeFileSync(filePath, content, "utf8");
  console.log(
    "✅ Fichier mis à jour avec succès à",
    now.toLocaleString("en-GB", { dateStyle: "full", timeStyle: "short" })
  );
}

// Comparaison : ici pour l’instant on décide d’actualiser à chaque exécution si besoin
updateTimestamp();
