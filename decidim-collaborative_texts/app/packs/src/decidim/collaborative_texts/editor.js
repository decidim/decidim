export default class Editor {
  constructor(selection) {
    this.selection = selection;
    this.templates = selection.document.templates;
    this.doc = selection.doc;
    this.wrapper = selection.wrapper;
    this.nodes = selection.nodes;
    this.firstNode = selection.firstNode;
    this.lastNode = selection.lastNode;
    this.editor = null;
    this.container = null;
    this._createEditor();
    this._setupContainer();
  }

  destroy() {
    if (!this.editor) {
      return;
    }
    this.editor.remove();
    this.editor = null;
  }

  _createEditor() {
    this.editor = window.document.createElement("div");
    this.editor.classList.add("collaborative-texts-editor");
    this.editor.innerHTML = this.templates.suggestionsEditor.innerHTML;
    this.editor.querySelector(".collaborative-texts-button-save").addEventListener("click", this._save.bind(this));
    this.editor.querySelector(".collaborative-texts-button-cancel").addEventListener("click", this._cancel.bind(this));
    this.wrapper.after(this.editor);
  }
  
  _setupContainer() {   
    // This in the future should be the tiptap editor
    this.container = this.editor.querySelector(".collaborative-texts-editor-container");
    this.container.innerHTML = this.nodes.map((node) => node.outerHTML).join("");
    this.container.contentEditable = true;
    this.container.focus();
  }

  _save() {
    console.log("save editor", this)
    const event = new CustomEvent("collaborative-texts:suggest", {
      detail: {
        nodes: this.nodes,
        firstNode: this.firstNode,
        lastNode: this.lastNode,
        replaceNodes: this.container.childNodes
      }
    });
    this.doc.dispatchEvent(event);
    this.selection.clear();
  }

  _cancel() {
    this.selection.clear();
  }
}

