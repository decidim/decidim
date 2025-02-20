import Menu from 'src/decidim/collaborative_texts/menu';
import Editor from 'src/decidim/collaborative_texts/editor';

class Selection {
  constructor(doc, i18n) {
    this.doc = doc;
    this.i18n = i18n || {};
    this.selection = document.getSelection();
    this.nodes = {};
    this.firstNode = null;
    this.lastNode = null;
    this.wrapper = null;
    this.editor = null;
    this.menu = null;
    this.range = null;
    this.blocked = false;
    // Multiple selections are not supported
    if (this.selection.rangeCount > 1) {
      console.error("Multiple selections are not supported");
    }
    console.log("Selection: ", this);
  }
  
  detectNodes() {
    this.range = this.selection.getRangeAt(0);
    let node;
    for(let i=0; i<this.doc.childNodes.length; i++) {
      node = this.doc.childNodes[i];
      if (this.range.intersectsNode(node)) {
        this.nodes[i] = node;
        this.firstNode = this.firstNode || node;
        this.lastNode = node;
      }
    }
    return this;
  }

  wrap() {
    // console.log("Wrap selection");
    this.blocked = true;
    this.wrapper = document.createElement("div");
    this.wrapper.classList.add("collaborative-texts-selection");
    this.firstNode.before(this.wrapper);
    this.nodes.forEach(node => {
      this.wrapper.appendChild(node);
    });
    return this;
  }

  unWrap() {
    // console.log("Unwrap selection");
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
    return this;
  }

  showEditor() {
    this.editor = new Editor(this);
    return this;
  }

  clear() {
    // console.log("Clear current edition");
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