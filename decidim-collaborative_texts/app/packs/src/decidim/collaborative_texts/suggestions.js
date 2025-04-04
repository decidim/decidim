import Suggestion from "src/decidim/collaborative_texts/suggestion";

export default class Suggestions {
  constructor(document) {
    this.document = document;
    this.nodes = document.nodes;
    this.doc = document.doc;
    this.i18n = document.i18n || {};
    this.suggestions = [];
    this._fetchSuggestions();
    this._bindEvents();
  }
  
  resetPositions() {
    this.suggestions.forEach((suggestion) => suggestion.resetPosition());
    return this;
  }
  
  // restore changes for any suggestion affecting the specified nodes
  restore(nodes, except = []) {
    this.suggestions.forEach((suggestion) => {
      if (!except.includes(suggestion) && suggestion.nodes.some((node) => nodes.includes(node))) {
        suggestion.restore();
      }
    });
  }

  getApplied() {
    return this.suggestions.filter((suggestion) => suggestion.applied);
  }

  getPending() {
    return this.suggestions.filter((suggestion) => !suggestion.applied);
  }

  // destroy all suggestions
  destroy() {
    this.suggestions.forEach((suggestion) => suggestion.destroy());
    this.suggestions = [];
    return this;
  }
  
  _fetchSuggestions() {
    console.log("Fetch suggestions", this);
    fetch(this.doc.dataset.collaborativeTextsSuggestionsUrl).
      then((response) => response.json()).
      then((data) => {
        data.forEach((item) => {
          let suggestion = new Suggestion(this, item)
          if (suggestion.valid) {
            this.suggestions.push(suggestion);
          }
        });
      });
  }

  _bindEvents() {
    this.doc.addEventListener("collaborative-texts:applied", this._onSuggestionApplied.bind(this));
    this.doc.addEventListener("collaborative-texts:restored", this._onSuggestionRestored.bind(this));
  }

  _onSuggestionApplied() {
    this.resetPositions();
  }

  _onSuggestionRestored() {
    this.resetPositions();
  }

}
