import confirmDialog from "src/decidim/confirm";
export default class Manager {
  constructor(document) {
    this.document = document;
    this.suggestions = document.suggestionsList.suggestions;
    this.doc = document.doc;
    this.i18n = document.i18n || {};
    this.div = window.document.getElementsByClassName("collaborative-texts-manager")[0];
    this.rolloutButton = this.div.querySelector("[data-collaborative-texts-manager-rollout]");
    this.consolidateButton = this.div.querySelector("[data-collaborative-texts-manager-consolidate]");
    this.cancelButton = this.div.querySelector("[data-collaborative-texts-manager-cancel]");
    this.counters = {
      applied: [...this.div.getElementsByClassName("collaborative-texts-manager-applied")],
      pending: [...this.div.getElementsByClassName("collaborative-texts-manager-pending")]
    };
    this._bindEvents();
  }

  updateCounters(applied, pending) {
    this.counters.applied.forEach((counter) => {
      counter.textContent = applied;
    });
    this.counters.pending.forEach((counter) => {
      counter.textContent = pending;
    });
  }

  show() {
    if (this.div)  {
      this.div.classList.remove("hidden");
    }
  }

  hide() {
    this.div.classList.add("hidden");
  }

  cancel() {
    this.suggestions.forEach((suggestion) => suggestion.restore());
    this.hide();
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
      if ([...node.classList].find((cls) => cls.startsWith("collaborative-texts-"))) {
        return;
      }
      this.container.appendChild(node.cloneNode(true));
    });
    return this.container.innerHTML;
  }

  _save(event) {
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
            accepted: this.document.suggestionsList.getApplied().map((suggestion) => suggestion.id),
            pending: this.document.suggestionsList.getPending().map((suggestion) => suggestion.id),
            draft: draft
          })
        }).
          then(async (response) => {
            const data = await response.json();
            if (!response.ok) {
              throw new Error(data.message
                ? data.message
                : data);
            }
            window.location.href = data.redirect;
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
    this.cancelButton.addEventListener("click", this.cancel.bind(this));
  }
}
