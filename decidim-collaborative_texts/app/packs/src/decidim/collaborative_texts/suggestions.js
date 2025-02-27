import Suggestion from "src/decidim/collaborative_texts/suggestion";

class Suggestions {
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
  
  _fetchSuggestions() {
    console.log("Fetch suggestions", this);
    // fetch(this.doc.dataset.collaborativeTextsSuggestionsUrl)
    //   .then(response => response.json())
    //   .then(data => {
    //     this.suggestions = data;
    //     this._updateSuggestions();
    //   });
    let fromServer = [
      {
        firstNode: "10",
        lastNode: "12",
        replace: [
          "<p>Replacement A - line 1</p>",
          "<h4>Replacement A - line 2</h4>",
          "<p>Replacement A - line 3</p>",
          "<p>Replacement A - line 4</p>"
        ]
      },
      {
        firstNode: "10",
        lastNode: "11",
        replace: [
          "<p>Replacement A' - line 1</p>"
        ]
      },
      {
        firstNode: "20",
        lastNode: "22",
        replace: [
          "<p>Replacement B - line 1</p>",
          "<h4>Replacement B - line 2</h4>",
          "<p>Replacement B - line 3</p>"
        ]
      },
      {
        firstNode: "30",
        lastNode: "30",
        replace: [
          "<p>Replacement C - line 1</p>",
          "<h4>Replacement C - line 2</h4>",
          "<p>Replacement C - line 3</p>",
          "<p>Replacement C - line 4</p>",
          "<p>Replacement C - line 5</p>"
        ]
      }
    ]
    // assign existing nodes to the suggestions
    fromServer.forEach((item) => {
      let suggestion = new Suggestion(this, item)
      if (suggestion.valid) {
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
