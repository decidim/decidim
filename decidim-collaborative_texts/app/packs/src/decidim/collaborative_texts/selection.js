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

  getRanges() {
    const ranges = [];
    for (let idx = 0; idx < this.selection.rangeCount; idx++) { // eslint-disable-line no-plusplus
      ranges.push(this.selection.getRangeAt(idx));
    }
    return ranges;
  }

  isEditing() {
    if (!this.blocked) {
      return false;
    }
    if (this.changed()) {
      return true;
    }
    return false;
  }

  isValid() {
    if (this.selection.rangeCount === 0 || this.selection.isCollapsed) {
      return false;
    }
    this.detectNodes();
    if (this.nodes.length === 0) {
      return false;
    }
    return true;
  }

  detectNodes() {
    this.nodes = [];
    this.firstNode = null;
    this.lastNode = null;
    this.getRanges().forEach((range) => {
      this.doc.nodes.forEach((node, index) => {
        if (range.intersectsNode(node)) {
          this.nodes[index] = node;
          this.firstNode = this.firstNode || node;
          this.lastNode = node;
        }
      });
    });
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
    this.unWrap();
    if (this.editor) {
      this.editor.destroy();
    }
    this.blocked = false;
    return this;
  }
}

export default Selection;
