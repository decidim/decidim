import Selection from "src/decidim/collaborative_texts/selection";
import Suggestions from "src/decidim/collaborative_texts/suggestions";

class Document {
  constructor(doc) {
    this.doc = doc;
    this.selecting = false;
    this.active = false;
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
    console.log("Enable suggestions");
    document.addEventListener("selectstart", this._onSelectionStart.bind(this));
    document.addEventListener("mouseup", this._onSelectionEnd.bind(this));
    this.doc.addEventListener("collaborative-texts:suggest", this._onSuggest.bind(this));
    return this;
  }

  // fetches suggestions from the server and updates the UI with the wraps
  fetchSuggestions() {
    this.suggestions = new Suggestions(this, this.i18n);
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
    this._createEditor();
  }

  _createEditor() {
    this.selection = this.selection || new Selection(this.doc, this.i18n);
    if (this.selection.blocked) {
      return;
    }
    this.selection.clear().detectNodes();
    if (this.selection.nodes.length > 0) {
      this.selection.wrap().showMenu();
    }
  }

  _onSuggest(event) {
    console.log("Suggest: ", event.detail);
    let nodes = event.detail.nodes.map((node) => node.outerHTML);
    let replace = [...event.detail.replace].map((node) => node.outerHTML);
    console.log("Nodes: ", nodes);
    console.log("Replace: ", replace);
  }
}


export default Document;
