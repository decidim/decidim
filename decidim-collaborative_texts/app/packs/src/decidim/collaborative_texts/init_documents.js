import Document from "src/decidim/collaborative_texts/document";

window.CollaborativeTextsDocuments = window.CollaborativeTextsDocuments || [];
document.addEventListener("DOMContentLoaded", () => {
  const documents = document.querySelectorAll("[data-collaborative-texts-document]");
  documents.forEach((doc) => {
    let document = new Document(doc);
    document.fetchSuggestions();
    if (document.active) {
      document.enableSuggestions();
    }

    window.CollaborativeTextsDocuments.push(document);
  });
});
