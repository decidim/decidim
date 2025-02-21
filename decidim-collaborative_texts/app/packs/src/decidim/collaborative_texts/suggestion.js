class Suggestion {
  constructor(suggestions, suggestion) {
    this.suggestions = suggestions;
    this.doc = suggestions.doc;
    this.indexes = suggestion.indexes;
    this.replace = suggestion.replace;
    this.menu = null;
    this.menuWrapper = null;
    this.wrapper = null;
    this.changesWrapper = null;
    this.applied = false;
    this.i18n = {
      apply: suggestions.i18n.apply || "Apply",
      restore: suggestions.i18n.restore || "Restore"
    }
    this.childNodes = [...this.doc.childNodes].filter((node) => !(node.classList && node.classList.toString().startsWith("collaborative-texts-")))
    this.nodes = this.indexes.map((index) => this.childNodes[index]).filter((node) => node);
    this.valid = this.nodes.length > 0;
    if (this.valid) {
      this.firstNode = this.nodes[0];
      this.lastNode = this.nodes[this.nodes.length - 1];
      this._createMenuWrapper();
      this._createMenu();
      this._bindEvents();
    }
  }
     
  apply() {
    console.log("Apply a change", this);
    if (this.changesWrapper) {
      return this;
    }
    this.applied = true;
    this.menu.querySelector(".collaborative-texts-button-apply").classList.add("hidden");
    this.menu.querySelector(".collaborative-texts-button-restore").classList.remove("hidden");
    this._createChangesWrapper();
    // restore any other changes affecting the same nodes
    this.suggestions.suggestions.forEach((suggestion) => {
      if (suggestion !== this && suggestion.nodes.some((node) => this.nodes.includes(node))) {
        suggestion.restore();
      }
    });
    this.nodes.forEach((node) => {
      node.classList.add("collaborative-texts-hidden");
    });
    this.replace.forEach((text) => {
      this.changesWrapper.insertAdjacentHTML("beforeend", text);
    });
    this.wrapper.classList.add("applied");
    let event = new CustomEvent("collaborative-texts:applied", { detail: { suggestion: this } });
    this.doc.dispatchEvent(event);
    return this;
  }

  restore() {
    if (this.changesWrapper) {
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
    if (!this.menuWrapper || !this.firstNode) {
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
    if (this.firstNode.previousSibling && this.firstNode.previousSibling.classList.contains("collaborative-texts-suggestions-menu")) {
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
