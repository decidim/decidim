import confirmDialog from "src/decidim/confirm";
export default class Manager {
  constructor(document) {
    this.document = document;
    this.doc = document.doc;
    this.i18n = document.i18n || {};
    this.div = window.document.getElementsByClassName("collaborative-texts-manager")[0];
    this.rolloutButton = this.div.querySelector("[data-collaborative-texts-manager-rollout]");
    this.consolidateButton = this.div.querySelector("[data-collaborative-texts-manager-consolidate]");
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
      if (node.classList.contains("collaborative-texts-changes")) {
        node.childNodes.forEach((child) => this.container.appendChild(child.cloneNode(true)));
        return;
      }
      if (node.classList.values().find((cls) => cls.startsWith("collaborative-texts-"))) {
        return;
      }
      this.container.appendChild(node.cloneNode(true));
    });
    return this.container.innerHTML;
  }

  _save(event) {
    console.log("Save manager", this, event);
    const draft = !event.target.dataset.collaborativeTextsManagerConsolidate;

    confirmDialog(draft
      ? this.i18n.rolloutConfirm
      : this.i18n.consolidateConfirm).then((accepted) => {
      if (accepted) {
        fetch(this.doc.dataset.collaborativeTextsRolloutUrl, {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
            "X-CSRF-Token": this.document.csrfToken
          },
          body: JSON.stringify({
            body: this.cleanBody(),
            accepted: this.document.suggestions.getApplied().map((suggestion) => suggestion.id),
            pending: this.document.suggestions.getPending().map((suggestion) => suggestion.id),
            draft: draft
          })
        }).
          then(async (response) => {
            const data = await response.json();
            console.log("Response", response, data);
            if (!response.ok) {
              throw new Error(data.message
                ? data.message
                : data);
            }
            location = data.redirect;
          }).
          catch((error) => {
            console.error("Error saving:", error);
            this.document.alert(error);
          });
      }
    });
    
  }

  _bindEvents() {
    this.rolloutButton.addEventListener("click", this._save.bind(this));
    this.consolidateButton.addEventListener("click", this._save.bind(this));
  }
}
