export default class Editor {
  constructor(selection) {
    this.selection = selection;
    this.templates = selection.doc.templates;
    this.doc = selection.doc.doc;
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
    this.saveButton = this.editor.querySelector(".collaborative-texts-button-save");
    this.cancelButton = this.editor.querySelector(".collaborative-texts-button-cancel");
    this.editor.addEventListener("keydown", (event) => {
      if (event.ctrlKey && event.key === "Enter") {
        event.preventDefault();
        this._save();
      }
    });
    this.saveButton.addEventListener("click", this._save.bind(this));
    this.cancelButton.addEventListener("click", this._cancel.bind(this));
    this.wrapper.after(this.editor);
  }

  _setupContainer() {
    // This in the future should be the tiptap editor
    this.container = this.editor.querySelector(".collaborative-texts-editor-container");
    this.container.innerHTML = this.nodes.map((node) => node.outerHTML).join("");
    this.originalHtml = this.container.innerHTML;
    this.container.contentEditable = true;
    this.container.addEventListener("input", this._change.bind(this));
    this.container.addEventListener("focusout", this._change.bind(this));
    this.container.focus();
  }

  _change() {
    const newHtml = this.container.innerHTML;
    if (newHtml === this.originalHtml) {
      this.saveButton.classList.add("disabled");
      this.saveButton.disabled = true;
    } else {
      this.saveButton.classList.remove("disabled");
      this.saveButton.disabled = false;
    }
  }

  _save() {
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

