import Selection from "src/decidim/collaborative_texts/selection";
import Suggestions from "src/decidim/collaborative_texts/suggestions";
import Manager from "src/decidim/collaborative_texts/manager";

export default class Document {
  constructor(doc) {
    this.doc = doc;
    this.selecting = false;
    this.applying = false;
    this.active = false;
    this.suggestions = [];
    this.templates = {
      suggestionsEditor: window.document.querySelector(this.doc.dataset.collaborativeTextsSuggestionsEditorTemplate),
      suggestionsBox: window.document.querySelector(this.doc.dataset.collaborativeTextsSuggestionsBoxTemplate),
      suggestionsBoxItem: window.document.querySelector(this.doc.dataset.collaborativeTextsSuggestionsBoxItemTemplate)
    }
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
    this.csrfToken = document.querySelector("meta[name=csrf-token]") && document.querySelector('meta[name="csrf-token"]').getAttribute("content");
    this.alertWrapper = window.document.querySelector(".collaborative-texts-alert");
    this.alertDiv = this.alertWrapper.querySelector("div");
    this._prepareNodes();
    // console.log("Document prepared", this);
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

  // show an alert message for 5 seconds
  alert(message) {
    this.alertDiv.textContent = message;
    this.alertWrapper.classList.remove("hidden");
    setTimeout(() => {
      this.alertWrapper.classList.add("hidden");
    }, 5000);
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
    if (this.selection.blocked) {
      if (this.selection.outsideBlock()) {
        this.alert(this.i18n.selectionActive)
      }
      return;
    }
    if (this.applying) {
      return;
    }
    this.selection.clear().detectNodes();
    if (this.selection.nodes.length > 0) {
      this.selection.wrap().showEditor();
    }
  }

  _onApply() {
    if (!this.doc.dataset.collaborativeTextsRolloutUrl) {
      return;
    }
    this.applying = true;
    this.manager = this.manager || new Manager(this);
    this.manager.show();
  }
  
  _onRestore() {
    if (!this.suggestions.suggestions.find((suggestion) => suggestion.applied)) {
      this.applying = false;
      this.manager.hide();
    }
  }

  _onSuggest(event) {
    let replace = [...event.detail.replaceNodes].map((node) => (node.nodeType === Node.TEXT_NODE
      ? node.textContent
      : node.outerHTML));
    console.log("firstNode: ", event.detail.firstNode.id);
    console.log("lastNode: ", event.detail.lastNode.id);
    console.log("Replace: ", replace);
    fetch(this.doc.dataset.collaborativeTextsSuggestionsUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest2",
        "X-CSRF-Token": this.csrfToken
      },
      body: JSON.stringify({
        firstNode: event.detail.firstNode.id.replace(/^ct-node-/, ""),
        lastNode: event.detail.lastNode.id.replace(/^ct-node-/, ""),
        replace: replace
      })
    }).
      then(async (response) => {
        const data = await response.json();
        if (!response.ok) {
          throw new Error(data.message
            ? data.message
            : data);
        }

        console.log("Suggestion sent:", data);
        this.suggestions.destroy();
        this.fetchSuggestions();
      }).
      catch((error) => {
        console.error("Error sending suggestion:", error);
        this.alert(error);
      });
  }
}

