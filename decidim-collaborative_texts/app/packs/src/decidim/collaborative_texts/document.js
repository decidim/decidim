import Selection from "src/decidim/collaborative_texts/selection";
import SuggestionsList from "src/decidim/collaborative_texts/suggestions_list";
import Manager from "src/decidim/collaborative_texts/manager";

export default class Document {
  constructor(doc) {
    this.doc = doc;
    this.selecting = false;
    this.applying = false;
    this.active = false;
    this.suggestionsList = null;
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
    this._bindManager();
  }

  // listen to new selections and allows the user to participate in the collaborative text
  enableSuggestions() {
    window.document.addEventListener("selectstart", this._onSelectionStart.bind(this));
    window.document.addEventListener("mouseup", this._onSelectionEnd.bind(this));
    return this;
  }

  // fetches suggestions from the server and updates the UI with the wraps
  fetchSuggestions() {
    this.suggestionsList = new SuggestionsList(this);
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

  // bind the manager to the document
  _bindManager() {
    this.doc.addEventListener("collaborative-texts:applied", this._onApply.bind(this));
    this.doc.addEventListener("collaborative-texts:restored", this._onRestore.bind(this));
    this.doc.addEventListener("collaborative-texts:suggest", this._onSuggest.bind(this));
  }

  // For all first level nodes of type ELEMENT_NODE, ensure they have a unique id if they do not have one starting with "ct-node-"
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
    if (window.document.getSelection().toString() === "") {
      this.selecting = false;
      return;
    }
    if (!this.selecting) {
      return;
    }
    this.selecting = false;
    this._showEditable();
  }

  _showEditable() {
    this.selection = this.selection || new Selection(this);
    if (this.applying) {
      return;
    }
    if (this.selection.isEditing()) {
      this.alert(this.i18n.selectionActive);
      this.selection.scrollIntoView();
      return;
    }
    if (this.selection.isValid()) {
      this.selection.clear().wrap().showEditor();
    }
  }

  _onApply() {
    if (!this.doc.dataset.collaborativeTextsRolloutUrl) {
      return;
    }
    this.applying = true;
    this.manager = this.manager || new Manager(this);
    this.manager.show();
    this.manager.updateCounters(this.suggestionsList.getApplied().length, this.suggestionsList.getPending().length);
  }

  _onRestore() {
    if (!this.suggestionsList.suggestions.find((suggestion) => suggestion.applied)) {
      this.applying = false;
      this.manager.hide();
    }
  }

  _sanitizeNodes(nodes) {
    return [...nodes].filter((node) => node).map((node) => (node.nodeType === Node.TEXT_NODE
      ? node.textContent
      : node.outerHTML));
  }

  _onSuggest(event) {
    let original = this._sanitizeNodes(event.detail.nodes);
    let replace = this._sanitizeNodes(event.detail.replaceNodes);
    fetch(this.doc.dataset.collaborativeTextsSuggestionsUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": this.csrfToken
      },
      body: JSON.stringify({
        firstNode: event.detail.firstNode.id.replace(/^ct-node-/, ""),
        lastNode: event.detail.lastNode.id.replace(/^ct-node-/, ""),
        original: original,
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

        if (this.suggestionsList) {
          this.suggestionsList.destroy();
        }
        this.fetchSuggestions();
      }).
      catch((error) => {
        console.error("Error sending suggestion:", error);
        this.alert(error);
      });
  }
}

