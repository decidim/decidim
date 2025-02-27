import Selection from "src/decidim/collaborative_texts/selection";
import Suggestions from "src/decidim/collaborative_texts/suggestions";

class Document {
  constructor(doc) {
    this.doc = doc;
    this.selecting = false;
    this.applying = false;
    this.active = false;
    this.suggestions = [];
    try  {
      this.active = JSON.parse(this.doc.dataset.collaborativeTextsDocument);
    } catch (_e) {
      console.error("Error parsing collaborativeTextsDocument", this.doc.dataset.collaborativeTextsDocument);
    }
    this.i18n = {};
    try {
      this.i18n = JSON.parse(this.doc.dataset.collaborativeTextsI18n);
    } catch (_e) {
      console.error("Error parsing collaborativeTextsI18n", this.doc.dataset.collaborativeTextsI18n);
    }
    this._prepareNodes();
    console.log("Document prepared", this);
  }

  // listen to new selections and allows the user to participate in the collaborative text
  enableSuggestions() {
    console.log("Enabling suggestions");
    window.document.addEventListener("selectstart", this._onSelectionStart.bind(this));
    window.document.addEventListener("mouseup", this._onSelectionEnd.bind(this));
    this.doc.addEventListener("collaborative-texts:applied", this._onApply.bind(this));
    this.doc.addEventListener("collaborative-texts:restored", this._onRestore.bind(this));
    this.doc.addEventListener("collaborative-texts:suggest", this._onSuggest.bind(this));
    return this;
  }

  // fetches suggestions from the server and updates the UI with the wraps
  fetchSuggestions() {
    this.suggestions = new Suggestions(this);
    return this;
  }

  // For all first level nodes of type ELEMENT_NODE, ensure they have a unique id if they don't have one starting with "ct-node-"
  _prepareNodes() {
    this.nodes = [];
    [...this.doc.childNodes].forEach((node) => {
      if (node.nodeType !== Node.ELEMENT_NODE) {
        return;
      }
      if (!node.id || !node.id.startsWith("ct-node-")) {
        node.id = `ct-node-${this.nodes.length + 1}`;
      }
      this.nodes.push(node);
    });
  }

  _onSelectionStart() {
    this.selecting = true;
  }

  _onSelectionEnd() {
    if (!this.selecting) {
      return;
    }
    this.selecting = false;
    this._showOptions();
  }

  _showOptions() {
    this.selection = this.selection || new Selection(this);
    if (this.selection.blocked || this.applying) {
      return;
    }
    this.selection.clear().detectNodes();
    if (this.selection.nodes.length > 0) {
      this.selection.wrap().showMenu();
    }
  }

  _onApply() {
    this.applying = true;
  }

  _onRestore() {
    if (!this.suggestions.suggestions.find((suggestion) => suggestion.applied)) {
      this.applying = false;
    }
  }

  _onSuggest(event) {
    let replace = [...event.detail.replace].map((node) => node.outerHTML);
    console.log("firstNode: ", event.detail.firstNode.id);
    console.log("lastNode: ", event.detail.lastNode.id);
    console.log("Replace: ", replace);
  }
}


export default Document;
