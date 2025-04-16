import Editor from "src/decidim/collaborative_texts/editor";

class Selection {
  constructor(doc) {
    this.doc = doc;
    this.selection = window.document.getSelection();
    this.nodes = [];
    this.firstNode = null;
    this.lastNode = null;
    this.wrapper = null;
    this.editor = null;
    this.blocked = false;
  }

  detectNodes() {
    for (let idx = 0; idx < this.selection.rangeCount; idx++) { // eslint-disable-line no-plusplus
      const range = this.selection.getRangeAt(idx);
      this.doc.nodes.forEach((node, index) => {
        if (range.intersectsNode(node)) {
          this.nodes[index] = node;
          this.firstNode = this.firstNode || node;
          this.lastNode = node;
        }
      });
    }
    return this;
  }

  changed() {
    return this.editor && !this.editor.saveButton.disabled;
  }

  scrollIntoView() {
    if (this.editor) {
      this.editor.editor.scrollIntoView({ behavior: "smooth", block: "nearest" });
    }
    return this;
  }

  outsideBlock() {
    const node = this.selection.focusNode;
    if (node) {
      if (node.parentNode.closest(".collaborative-texts-selection") || node.parentNode.closest(".collaborative-texts-editor-container")) {
        return false;
      }
    }
    return true;
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


  showEditor() {
    this.editor = new Editor(this);
    return this;
  }

  clear() {
    this.nodes = [];
    this.firstNode = null;
    this.lastNode = null;
    this.unWrap();
    if (this.editor) {
      this.editor.destroy();
    }
    this.blocked = false;
    return this;
  }
}

export default Selection;
