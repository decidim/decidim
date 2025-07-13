import {createDropdown, createAccordion} from "src/decidim/a11y";
import Accordions from "a11y-accordion-component";
export default class Suggestion {
  constructor(suggestionsList, entry) {
    this.id = entry.id;
    this.authorCell = entry.profileHtml;
    this.suggestionsList = suggestionsList;
    this.selection = suggestionsList.document.selection;
    this.templates = suggestionsList.document.templates;
    this.doc = suggestionsList.doc;
    this.nodes = [];
    for (const node of suggestionsList.nodes) {
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
    this.summary = entry.summary;
    this.item = null;
    this.boxWrapper = null;
    this.highlightWrapper = null;
    this.changesWrapper = null;
    this.applied = false;
    this.isFirst = false;
    this.valid = this.nodes.length > 0 && this.firstNode && this.lastNode && Array.isArray(this.replace);
    if (this.valid) {
      this._createBoxWrapper();
      this._createBoxItem();
      this._bindEvents();
    }
  }

  // Get the nodes that are affected by the suggestion
  siblingSuggestions() {
    return this.suggestionsList.suggestions.filter((suggestion) => {
      return suggestion.id !== this.id && suggestion.nodes.some((node) => this.nodes.includes(node));
    });
  }

  // wrap affected nodes by the suggestion in a div to temporarily apply the changes
  // this is used to highlight (or replace) the nodes when hovering the suggestion
  highlight() {
    // If applied, just add the style to the changesWrapper
    if (this.applied) {
      this.changesWrapper.classList.add("collaborative-texts-highlight");
      return;
    }
    this.highlightWrapper = window.document.createElement("div");
    this.highlightWrapper.classList.add("collaborative-texts-highlight");
    this.firstNode.before(this.highlightWrapper);
    this._hideOriginalNodes("collaborative-texts-highlight-hidden");
    this.siblingSuggestions().filter((suggestion) => suggestion.applied).forEach((suggestion) => {
      suggestion.changesWrapper.classList.add("collaborative-texts-highlight-hidden");
      suggestion.nodes.forEach((node) => node.classList.add("collaborative-texts-highlight-shown"));
    });
    this._applyTo(this.highlightWrapper);
  }

  // Restores the highlighted nodes to their original state
  // this is used to remove the highlight when leaving the suggestion
  blur() {
    // If applied, just remove the style from the changesWrapper
    if (this.applied && this.changesWrapper) {
      this.changesWrapper.classList.remove("collaborative-texts-highlight");
    }
    if (this.highlightWrapper) {
      this.highlightWrapper.remove();
      this.highlightWrapper = null;
      this._showOriginalNodes("collaborative-texts-highlight-hidden");
      this.siblingSuggestions().filter((suggestion) => suggestion.applied).forEach((suggestion) => {
        suggestion.changesWrapper.classList.remove("collaborative-texts-highlight-hidden");
        suggestion.nodes.forEach((node) => node.classList.remove("collaborative-texts-highlight-shown"));
      });
    }
  }

  // Apply the suggestion by replacing the nodes with the replace content
  apply() {
    if (!this.applied && !this.selection || !this.selection.blocked) {
      this.applied = true;
      if (this.highlightWrapper) {
        this.blur();
      }
      // restore any other changes affecting the same nodes
      this.suggestionsList.restore(this.nodes, [this]);
      this._createChangesWrapper();
      this._hideOriginalNodes();
      this._applyTo(this.changesWrapper);
      this.item.classList.add("applied");
      this._resetAccordion();
      let event = new CustomEvent("collaborative-texts:applied", { detail: { suggestion: this } });
      this.doc.dispatchEvent(event);
    }
    return this;
  }

  // Restore the suggestion by removing the replace content and showing the original nodes
  restore() {
    if (this.applied) {
      this.applied = false;
      this.item.classList.remove("applied");
      this._showOriginalNodes();
      this.changesWrapper.remove();
      this.changesWrapper = null;
      this._resetAccordion();
      let event = new CustomEvent("collaborative-texts:restored", { detail: { suggestion: this } });
      this.doc.dispatchEvent(event);
    }
    return this;
  }

  // Apply the changes to the wrapper passed as argument
  // this does not manipulate the DOM, but only the wrapper
  _applyTo(wrapper) {
    this.replace.forEach((text) => wrapper.insertAdjacentHTML("beforeend", text));
    // wrap in <p> any text nodes
    wrapper.childNodes.forEach((node) => {
      if (node.nodeType === Node.TEXT_NODE) {
        let paragraph = window.document.createElement("p");
        paragraph.textContent = node.textContent;
        node.replaceWith(paragraph);
      }
    });
  }

  _hideOriginalNodes(className = "collaborative-texts-hidden") {
    this.nodes.forEach((node) => node.classList.add(className));
  }

  _showOriginalNodes(className = "collaborative-texts-hidden") {
    this.nodes.forEach((node) => node.classList.remove(className));
  }

  getPosition() {
    let node = this.changesWrapper || this.highlightWrapper || this.firstNode;

    while (node.classList.contains("collaborative-texts-hidden") || node.classList.contains("hidden")) {
      node = node.previousSibling;
    }

    return node.offsetTop;
  }

  // Reset the position of the suggestion boxWrapper using the current position of the first node
  setPosition(position) {
    if (!this.boxWrapper) {
      return this;
    }
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
    if (this.highlightWrapper) {
      this.highlightWrapper.remove();
      this.highlightWrapper = null;
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

  // Because the A11y accordion has not an API to programmatically toggle the
  // accordion, we need to destroy and recreate it to reset the state
  _resetAccordion() {
    let accordion = this.boxWrapper.querySelector('[data-component="accordion"]');
    Accordions.destroy(accordion.id);
    createAccordion(accordion);
  }

  // Create a wrapper for all the suggestions applying to the same nodes
  _createBoxWrapper() {
    if (this.firstNode.previousSibling &&
        this.firstNode.previousSibling.nodeType === Node.ELEMENT_NODE &&
        this.firstNode.previousSibling.classList.contains("collaborative-texts-suggestions-box")) {
      this.boxWrapper = this.firstNode.previousSibling;
      return;
    }
    this.isFirst = true;
    this.boxWrapper = window.document.createElement("div");
    this.boxWrapper.id = `suggestion-box-wrapper-${this.id}`;
    this.boxWrapper.classList.add("collaborative-texts-suggestions-box");
    this.boxWrapper.innerHTML = this.templates.suggestionsBox.innerHTML.replaceAll("{{ID}}", this.id);
    this.firstNode.before(this.boxWrapper);
    this._resetAccordion();
  }

  // Create the box item for the suggestion inside the wrapper
  _createBoxItem() {
    this.boxItems = this.boxWrapper.querySelector(".collaborative-texts-suggestions-box-items");
    this.itemsCounts = this.boxWrapper.querySelectorAll(".collaborative-texts-suggestions-box-items-count");
    this.item = window.document.createElement("div");
    this.item.classList.add("collaborative-texts-suggestions-box-item");
    this.item.innerHTML = this.templates.suggestionsBoxItem.innerHTML.replaceAll("{{ID}}", this.id).replaceAll("{{PROFILE}}", this.authorCell);
    this.text = this.item.querySelector(".collaborative-texts-suggestions-box-item-text");
    this.text.innerHTML = this.summary;
    this.boxItems.appendChild(this.item);
    this.dropdown = this.item.querySelector('[data-component="dropdown"]');
    if (this.doc.dataset.collaborativeTextsRolloutUrl) {
      createDropdown(this.dropdown);
    } else {
      this.dropdown.remove();
    }
    this.itemsCounts.forEach((item) => {
      item.textContent = this.boxItems.childElementCount;
    });
  }

  _resetDropdown() {

  }

  _bindEvents() {
    this.item.addEventListener("mouseenter", this.highlight.bind(this));
    this.item.addEventListener("mouseleave", this.blur.bind(this));
    this.item.querySelector(".button-apply").addEventListener("click", this.apply.bind(this));
    this.item.querySelector(".button-restore").addEventListener("click", this.restore.bind(this));
  }
}
