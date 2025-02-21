import Suggestion from "src/decidim/collaborative_texts/suggestion";

class Suggestions {
  constructor(doc, i18n) {
    this.doc = doc;
    this.i18n = i18n || {};
    this.suggestions = [];
    console.log("Fetch suggestions", this);
    this._fetchSuggestions();
    this._bindEvents();
  }
  
  resetPositions() {
    this.suggestions.forEach((suggestion) => {
      suggestion.resetPosition();
    });
    return this;
  }

  _fetchSuggestions() {
    // fetch(this.doc.dataset.collaborativeTextsSuggestionsUrl)
    //   .then(response => response.json())
    //   .then(data => {
    //     this.suggestions = data;
    //     this._updateSuggestions();
    //   });
    let fromServer = [
      {
        indexes: [10, 11, 12],
        replace: [
          "<p>Replacement A - line 1</p>",
          "<h4>Replacement A - line 2</h4>",
          "<p>Replacement A - line 3</p>",
          "<p>Replacement A - line 4</p>"
        ]
      },
      {
        indexes: [10, 11],
        replace: [
          "<p>Replacement A' - line 1</p>"
        ]
      },
      {
        indexes: [20, 21, 22],
        replace: [
          "<p>Replacement B - line 1</p>",
          "<h4>Replacement B - line 2</h4>",
          "<p>Replacement B - line 3</p>"
        ]
      },
      {
        indexes: [30, 31],
        replace: [
          "<p>Replacement C - line 1</p>"
        ]
      }
    ]
    // assign existing nodes to the suggestions
    fromServer.forEach((item) => {
      let suggestion = new Suggestion(this, item)
      if (suggestion.nodes.length > 0) {
        this.suggestions.push(suggestion);
      }
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

export default Suggestions;
