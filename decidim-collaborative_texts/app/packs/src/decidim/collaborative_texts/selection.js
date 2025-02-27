import Menu from "src/decidim/collaborative_texts/menu";
import Editor from "src/decidim/collaborative_texts/editor";

class Selection {
  constructor(document) {
    this.document = document;
    this.doc = document.doc;
    this.i18n = document.i18n || {};
    this.selection = window.document.getSelection();
    this.nodes = {};
    this.firstNode = null;
    this.lastNode = null;
    this.wrapper = null;
    this.editor = null;
    this.menu = null;
    this.blocked = false;
  }
  
  detectNodes() {
    for (let idx = 0; idx < this.selection.rangeCount; idx++) { // eslint-disable-line no-plusplus
      const range = this.selection.getRangeAt(idx);
      this.document.nodes.forEach((node, index) => {
        if (range.intersectsNode(node)) {
          this.nodes[index] = node;
          this.firstNode = this.firstNode || node;
          this.lastNode = node;
        }
      });
    }
    return this;
  }

  wrap() {
    this.blocked = true;
    this.wrapper = window.document.createElement("div");
    this.wrapper.classList.add("collaborative-texts-selection");
    this.firstNode.before(this.wrapper);
    this.nodes.forEach((node) => this.wrapper.appendChild(node));
    return this;
  }

  unWrap() {
    if (this.wrapper) {
      while (this.wrapper.firstChild) {
        this.wrapper.parentNode.insertBefore(this.wrapper.firstChild, this.wrapper);
      }
      this.wrapper.remove();
    }
    return this;
  }


  showMenu() {
    this.menu = new Menu(this);
    this.selection.empty();
    return this;
  }

  showEditor() {
    this.editor = new Editor(this);
    return this;
  }

  clear() {
    this.nodes = [];
    this.firstNode = null;
    this.lastNode = null;
    this.unWrap();
    if (this.menu) {
      this.menu.destroy();
    }
    if (this.editor) {
      this.editor.destroy();
    }
    this.blocked = false;
    return this;
  }
}

export default Selection;
