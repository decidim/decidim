class Suggestion {
  constructor(suggestions, config) {
    this.suggestions = suggestions;
    this.doc = suggestions.doc;
    this.nodes = [];
    for (const node of suggestions.nodes) {
      if (node.id === `ct-node-${config.firstNode}`) { 
        this.firstNode = node;
      }
      if (node.id === `ct-node-${config.lastNode}`) {
        this.lastNode = node;
      }
      if (this.firstNode) {
        this.nodes.push(node);
      }
      if (this.lastNode) {
        break;
      }
    }
    this.replace = config.replace;
    this.menu = null;
    this.menuWrapper = null;
    this.wrapper = null;
    this.changesWrapper = null;
    this.applied = false;
    this.i18n = {
      apply: suggestions.i18n.apply || "Apply",
      restore: suggestions.i18n.restore || "Restore"
    }
    this.valid = this.nodes.length > 0 && this.firstNode && this.lastNode && Array.isArray(this.replace);
    console.log("Suggestion", suggestions, config, this);
    if (this.valid) {
      this._createMenuWrapper();
      this._createMenu();
      this._bindEvents();
    }
  }

  // Apply the suggestion by replacing the nodes with the replace content
  apply() {
    if (!this.applied) {
      console.log("Apply a change", this);
      this.applied = true;
      this.menu.querySelector(".collaborative-texts-button-apply").classList.add("hidden");
      this.menu.querySelector(".collaborative-texts-button-restore").classList.remove("hidden");
      // restore any other changes affecting the same nodes
      this.suggestions.restore(this.nodes, [this]);
      this._createChangesWrapper();
      this.nodes.forEach((node) => {
        node.classList.add("collaborative-texts-hidden");
      });
      this.replace.forEach((text) => {
        this.changesWrapper.insertAdjacentHTML("beforeend", text);
      });
      this.wrapper.classList.add("applied");
      let event = new CustomEvent("collaborative-texts:applied", { detail: { suggestion: this } });
      this.doc.dispatchEvent(event);
    }
    return this;
  }

  // Restore the suggestion by removing the replace content and showing the original nodes
  restore() {
    if (this.applied) {
      console.log("Restore a change", this);
      this.applied = false;
      this.menu.querySelector(".collaborative-texts-button-apply").classList.remove("hidden");
      this.menu.querySelector(".collaborative-texts-button-restore").classList.add("hidden");
      this.changesWrapper.remove();
      this.changesWrapper = null;
      this.nodes.forEach((node) => {
        node.classList.remove("collaborative-texts-hidden");
      });
      let event = new CustomEvent("collaborative-texts:restored", { detail: { suggestion: this } });
      this.doc.dispatchEvent(event);
    }
    return this;
  }

  resetPosition() {
    console.log("Reset position", this);
    if (!this.menuWrapper || !this.firstNode || this.firstNode.nodeType !== Node.ELEMENT_NODE) {
      return this;
    }
    let docTop = this.doc.getBoundingClientRect().top;
    let offsetTop = this.firstNode.getBoundingClientRect().top;
    let node = this.firstNode;
    while (node.offsetHeight === 0) {
      offsetTop = node.previousSibling.getBoundingClientRect().top;
      node = node.previousSibling;
    }

    this.menuWrapper.style.top = `${offsetTop - docTop - 10}px`;
    return this;
  }

  _createChangesWrapper() {
    this.changesWrapper = document.createElement("div");
    this.changesWrapper.classList.add("collaborative-texts-changes");
    this.firstNode.before(this.changesWrapper);
  }

  _createMenuWrapper() {
    if (this.firstNode.previousSibling &&
        this.firstNode.previousSibling.nodeType === Node.ELEMENT_NODE &&
        this.firstNode.previousSibling.classList.contains("collaborative-texts-suggestions-menu")) {
      this.menuWrapper = this.firstNode.previousSibling;
      return;
    }
    this.menuWrapper = document.createElement("div");
    this.menuWrapper.classList.add("collaborative-texts-suggestions-menu");
    this.resetPosition().firstNode.before(this.menuWrapper);
  }

  _createMenu() {
    this.menu = document.createElement("div");
    this.menu.classList.add("collaborative-texts-suggestions-menu-item");
    let truncatedText = `${this.replace.map((text) => text.replace(/<[^>]*>?/gm, "")).join(" ").substring(0, 30)}...`;
    this.menu.innerHTML = `<p>${truncatedText}</p><button class="collaborative-texts-button-apply">${this.i18n.apply}</button><button class="collaborative-texts-button-restore hidden">${this.i18n.restore}</button>`;
    this.menuWrapper.appendChild(this.menu);
  }

  _bindEvents() {
    this.menu.addEventListener("mouseenter", this._highlight.bind(this));
    this.menu.addEventListener("mouseleave", this._blur.bind(this));
    this.menu.querySelector(".collaborative-texts-button-apply").addEventListener("click", this.apply.bind(this));
    this.menu.querySelector(".collaborative-texts-button-restore").addEventListener("click", this.restore.bind(this));
  }

  _highlight() {
    // wrap affected nodes
    if (this.changesWrapper) {
      this.changesWrapper.classList.add("collaborative-texts-highlight");
      return;
    }
    this.wrapper = document.createElement("div");
    this.wrapper.classList.add("collaborative-texts-highlight");
    this.firstNode.before(this.wrapper);
    this.nodes.forEach((node) => {
      this.wrapper.appendChild(node);
    });
  }

  _blur() {
    if (this.changesWrapper) {
      this.changesWrapper.classList.remove("collaborative-texts-highlight");
    }
    if (this.wrapper) {
      while (this.wrapper.firstChild) {
        this.wrapper.parentNode.insertBefore(this.wrapper.firstChild, this.wrapper);
      }
      this.wrapper.remove();
      this.wrapper = null;
    }
  }
}

export default Suggestion;
