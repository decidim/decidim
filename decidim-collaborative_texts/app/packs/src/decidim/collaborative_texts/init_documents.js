import Document from "src/decidim/collaborative_texts/document";
import Toc from "src/decidim/collaborative_texts/toc";

window.CollaborativeTextsDocuments = window.CollaborativeTextsDocuments || {};
window.CollaborativeTextsToc = window.CollaborativeTextsToc || {};
window.document.addEventListener("DOMContentLoaded", () => {
  const documents = window.document.querySelectorAll("[data-collaborative-texts-document]");
  const tableOfContents = window.document.querySelectorAll("[data-collaborative-texts-toc]");
  documents.forEach((doc) => {
    let document = new Document(doc);
    document.fetchSuggestions();
    if (document.active) {
      document.enableSuggestions();
    }

    window.CollaborativeTextsDocuments[doc.id] = document;
  });

  tableOfContents.forEach((tocEl) => {
    let document = window.CollaborativeTextsDocuments[tocEl.dataset.collaborativeTextsToc];
    if (document) {
      let toc = new Toc(tocEl, document.doc);
      toc.render();
      window.CollaborativeTextsToc[tocEl.id] = toc;
    }
  });
});
