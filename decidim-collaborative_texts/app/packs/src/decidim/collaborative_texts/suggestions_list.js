import Suggestion from "src/decidim/collaborative_texts/suggestion";

export default class SuggestionsList {
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
    if (this.restoreTimeout) {
      console.log("Clearing restore timeout");
      clearTimeout(this.restoreTimeout);
      this.restoreTimeout = null;
    }
    // Restore the positions after a timeout to allow the DOM to update
    // and avoid flickering
    this.restoreTimeout = setTimeout(() => {
      const offset = 54;
      const positions = this.defaultSuggestions().map((suggestion) => [suggestion, suggestion.getPosition()]);
      positions.sort((one, two) => one[1] - two[1]);
      for (let i = 0; i < positions.length - 1; i++) { // eslint-disable-line
        const floor = offset * Math.floor(positions[i][1] / offset);
        const nextFloor = offset * Math.floor(positions[i + 1][1] / offset);
        if (floor === nextFloor) {
          console.log("Adjusting position", positions[i + 1][1], "to avoid overlap with", positions[i][1]);
          positions[i + 1][1] += offset - (positions[i + 1][1] - positions[i][1]);
          console.log("Adjusted position", positions[i + 1][1]);
        }
      }
      console.log("Restoring positions", positions);
      positions.forEach(([suggestion, position]) => suggestion.setPosition(position));
    }, 100);
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

  // The applied suggestion for each boxWrapper or the first suggestion if none is applied
  defaultSuggestions() {
    let suggestions = {};
    this.suggestions.forEach((suggestion) => {
      if (suggestion.applied) {
        suggestions[suggestion.boxWrapper.id] = suggestion;
      } else if (!suggestions[suggestion.boxWrapper] && suggestion.isFirst) {
        suggestions[suggestion.boxWrapper.id] = suggestion;
      }
    });
    return Object.values(suggestions);
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
        this.resetPositions();
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
