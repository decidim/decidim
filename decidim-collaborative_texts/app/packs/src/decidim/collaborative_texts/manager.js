class Manager {
  constructor(document) {
    this.document = document;
    this.doc = document.doc;
    this.i18n = document.i18n || {};
    this.div = window.document.getElementsByClassName("collaborative-texts-manager")[0];
    this.saveButton = this.div.querySelector("[data-collaborative-texts-manager-save]");
    this._bindEvents();
  }

  show() {
    if (this.div)  {
      this.div.classList.remove("hidden");
      console.log("Show manager", this);
    }
  }

  hide() {
    this.div.classList.add("hidden");
    console.log("Hide manager", this);
  }


  // Duplicates the body of the document, removing non accepted suggestions
  // Accepted suggestions nodes are converted to first level nodes
  cleanBody() {
    this.container = window.document.createElement("div");
    this.doc.childNodes.forEach((node) => {
      if (node.nodeType !== Node.ELEMENT_NODE) {
        return;
      }
      if (node.classList.contains("collaborative-texts-suggestions-menu")) {
        return;
      }
      if (node.classList.contains("collaborative-texts-editor")) {
        return;
      }
      if (node.classList.contains("collaborative-texts-hidden")) {
        return;
      }
      if (node.classList.contains("collaborative-texts-changes")) {
        node.childNodes.forEach((child) => this.container.appendChild(child.cloneNode(true)));
        return;
      }
      this.container.appendChild(node.cloneNode(true));
    });
    return this.container.innerHTML;
  }

  _save() {
    console.log("Save manager", this);
    fetch(this.doc.dataset.collaborativeTextsRolloutUrl, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.document.csrfToken
      },
      body: JSON.stringify({
        body: this.cleanBody(),
        accepted: this.document.suggestions.getApplied().map((suggestion) => suggestion.id)
      })
    }).
      then((response) => response.json()).
      then((data) => {
        console.log("Saved", data);
        location = data.redirect;
      });
  }

  _bindEvents() {
    this.saveButton.addEventListener("click", this._save.bind(this));
  }
}

export default Manager;
