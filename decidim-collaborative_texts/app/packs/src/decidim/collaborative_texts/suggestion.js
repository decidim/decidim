import {createDropdown, createAccordion} from "src/decidim/a11y";
export default class Suggestion {
  constructor(suggestions, entry) {
    this.id = entry.id;
    this.authorCell = entry.profileHtml;
    this.suggestions = suggestions;
    this.selection = suggestions.document.selection;
    this.templates = suggestions.document.templates;
    this.doc = suggestions.doc;
    this.nodes = [];
    for (const node of suggestions.nodes) {
      if (node.id === `ct-node-${entry.changeset.firstNode}`) { 
        this.firstNode = node;
      }
      if (node.id === `ct-node-${entry.changeset.lastNode}`) {
        this.lastNode = node;
      }
      if (this.firstNode) {
        this.nodes.push(node);
      }
      if (this.lastNode) {
        break;
      }
    }
    this.replace = entry.changeset.replace;
    this.item = null;
    this.boxWrapper = null;
    this.wrapper = null;
    this.changesWrapper = null;
    this.applied = false;
    this.valid = this.nodes.length > 0 && this.firstNode && this.lastNode && Array.isArray(this.replace);
    if (this.valid) {
      this._createBoxWrapper();
      this._createBoxItem();
      this._bindEvents();
    }
  }

  // Apply the suggestion by replacing the nodes with the replace content
  apply() {
    if (!this.applied && !this.selection || !this.selection.blocked) {
      console.log("Apply a change", this);
      this.applied = true;
      this.item.classList.add("applied");
      this.applyButton.classList.add("hidden");
      this.restoreButton.classList.remove("hidden");
      // restore any other changes affecting the same nodes
      this.suggestions.restore(this.nodes, [this]);
      this._createChangesWrapper();
      this.nodes.forEach((node) => node.classList.add("collaborative-texts-hidden"));
      this.replace.forEach((text) => this.changesWrapper.insertAdjacentHTML("beforeend", text));
      // wrap in <p> any text nodes
      this.changesWrapper.childNodes.forEach((node) => {
        if (node.nodeType === Node.TEXT_NODE) {
          let paragraph = window.document.createElement("p");
          paragraph.textContent = node.textContent;
          node.replaceWith(paragraph);
        }
      });
      if (this.wrapper) {
        this.wrapper.classList.add("applied");
      }
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
      this.item.classList.remove("applied");
      this.applyButton.classList.remove("hidden");
      this.restoreButton.classList.add("hidden");
      this.changesWrapper.remove();
      this.changesWrapper = null;
      this.nodes.forEach((node) => node.classList.remove("collaborative-texts-hidden"));
      let event = new CustomEvent("collaborative-texts:restored", { detail: { suggestion: this } });
      this.doc.dispatchEvent(event);
    }
    return this;
  }

  resetPosition() {
    if (!this.boxWrapper || !this.firstNode || this.firstNode.nodeType !== Node.ELEMENT_NODE) {
      return this;
    }
    let docTop = this.doc.getBoundingClientRect().top;
    let offsetTop = this.firstNode.getBoundingClientRect().top;
    let node = this.firstNode;

    try {
      while (node.offsetHeight === 0) {
        offsetTop = node.previousSibling.getBoundingClientRect().top;
        node = node.previousSibling;
      }
    } catch (error) {
      console.error(error);
    }
    let position = offsetTop - docTop - 10;
    // Check that the current position does not have already a suggestion boxWrapper in there already
    console.log("Position", position, this);
    this.suggestions.suggestions.forEach((suggestion) => {
      if (suggestion.boxWrapper && suggestion.boxWrapper !== this.boxWrapper) {
        let top = 10 * Math.round(parseInt(suggestion.boxWrapper.style.top, 10) / 10);
        if (top === 10 * Math.round(position / 10)) {
          position += 54;
        }
      }
    });

    this.boxWrapper.style.top = `${position}px`;
    return this;
  }

  destroy() {
    if (this.item) {
      this.item.remove();
      this.item = null;
    }
    if (this.boxWrapper) {
      this.boxWrapper.remove();
      this.boxWrapper = null;
    }
    if (this.wrapper) {
      this.wrapper.remove();
      this.wrapper = null;
    }
    if (this.changesWrapper) {
      this.changesWrapper.remove();
      this.changesWrapper = null;
    }
  }

  // Create a wrapper where to put the changes when applying the suggestion
  // Replaced nodes will be hidden, and the changes will be inserted in the wrapper
  _createChangesWrapper() {
    this.changesWrapper = window.document.createElement("div");
    this.changesWrapper.classList.add("collaborative-texts-changes");
    this.firstNode.before(this.changesWrapper);
  }

  // Create a wrapper for all the suggestions applying to the same nodes
  _createBoxWrapper() {
    if (this.firstNode.previousSibling &&
        this.firstNode.previousSibling.nodeType === Node.ELEMENT_NODE &&
        this.firstNode.previousSibling.classList.contains("collaborative-texts-suggestions-box")) {
      this.boxWrapper = this.firstNode.previousSibling;
      return;
    }
    this.boxWrapper = window.document.createElement("div");
    this.boxWrapper.classList.add("collaborative-texts-suggestions-box");
    this.boxWrapper.innerHTML = this.templates.suggestionsBox.innerHTML.replaceAll("{{ID}}", this.id);
    this.resetPosition().firstNode.before(this.boxWrapper);
    createAccordion(this.boxWrapper.querySelector('[data-component="accordion"]'));
  }
  
  // Create the box item for the suggestion inside the wrapper
  _createBoxItem() {
    this.boxItems = this.boxWrapper.querySelector(".collaborative-texts-suggestions-box-items");
    this.itemsCounts = this.boxWrapper.querySelectorAll(".collaborative-texts-suggestions-box-items-count");
    this.item = window.document.createElement("div");
    this.item.classList.add("collaborative-texts-suggestions-box-item");
    this.item.innerHTML = this.templates.suggestionsBoxItem.innerHTML.replaceAll("{{ID}}", this.id).replaceAll("{{PROFILE}}", this.authorCell);
    this.text = this.item.querySelector(".collaborative-texts-suggestions-box-item-text");
    this.applyButton = this.item.querySelector(".collaborative-texts-button-apply");
    this.restoreButton = this.item.querySelector(".collaborative-texts-button-restore");
    this._setText();
    this.boxItems.appendChild(this.item);
    createDropdown(this.item.querySelector('[data-component="dropdown"]'));
    this.itemsCounts.forEach((item) => {
      item.textContent = this.boxItems.childElementCount;
    });
  }

  _bindEvents() {
    this.item.addEventListener("mouseenter", this._highlight.bind(this));
    this.item.addEventListener("mouseleave", this._blur.bind(this));
    this.applyButton.addEventListener("click", this.apply.bind(this));
    this.restoreButton.addEventListener("click", this.restore.bind(this));
  }

  // wrap affected nodes by the suggestion in a div
  // this is used to highlight (or replace) the nodes when hovering the suggestion
  _highlight() {
    if (this.changesWrapper) {
      this.changesWrapper.classList.add("collaborative-texts-highlight");
      return;
    }
    this.wrapper = window.document.createElement("div");
    this.wrapper.classList.add("collaborative-texts-highlight");
    this.firstNode.before(this.wrapper);
    this.nodes.forEach((node) => this.wrapper.appendChild(node));
  }

  _setText() {
    const summary = this.replace.map((text) => text.replace(/<[^>]*>?/gm, "")).join(" ");
    this.text.textContent = summary.length > 300
      ? `${summary.substring(0, 300)}...`
      : summary;
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
