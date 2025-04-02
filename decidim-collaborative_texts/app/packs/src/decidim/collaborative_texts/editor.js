export default class Editor {
  constructor(selection) {
    this.selection = selection;
    this.wrapper = selection.wrapper;
    this.nodes = selection.nodes;
    this.firstNode = selection.firstNode;
    this.lastNode = selection.lastNode;
    this.editor = null;
    this.container = null;
    this.menu = null;
    this.i18n = {
      save: selection.i18n.save || "Save",
      cancel: selection.i18n.cancel || "Cancel"
    }
    this._createEditor();
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
    this._createContainer();
    this._createMenu();
    this.wrapper.after(this.editor);
    setTimeout(() => {
      this.container.focus();
    }, 0);
  }

  _createContainer() {   
    this.container = window.document.createElement("div");
    this.container.classList.add("collaborative-texts-editor-container");
    this.container.innerHTML = this.nodes.map((node) => node.outerHTML).join("");
    // This in the future should be the tiptap editor
    this.container.contentEditable = true;
    this.editor.appendChild(this.container);
  }

  _createMenu() {
    this.menu = window.document.createElement("div");
    this.menu.classList.add("collaborative-texts-editor-menu");
    this.menu.innerHTML = `<button class="collaborative-texts-button-save">${this.i18n.save}</button><button class="collaborative-texts-button-cancel">${this.i18n.cancel}</button>`;
    this.editor.appendChild(this.menu);
    this.menu.style.top = `${this.wrapper.getBoundingClientRect().top - this.selection.doc.getBoundingClientRect().top}px`;
    this._bindEvents();
  }

  _bindEvents() {
    this.menu.querySelector(".collaborative-texts-button-save").addEventListener("click", this._save.bind(this));
    this.menu.querySelector(".collaborative-texts-button-cancel").addEventListener("click", this._cancel.bind(this));
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
    this.selection.doc.dispatchEvent(event);
    this.selection.clear();
  }

  _cancel() {
    this.selection.clear();
  }
}

