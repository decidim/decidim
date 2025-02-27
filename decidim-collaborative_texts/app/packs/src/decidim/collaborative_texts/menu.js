class Menu {
  constructor(selection) {
    this.selection = selection;
    this.wrapper = selection.wrapper;
    this.doc = selection.doc;
    this.menu = null;
    this.i18n = {
      suggest: selection.i18n.suggest || "Suggest a change",
      cancel: selection.i18n.cancel || "Cancel"
    }
    this._createMenu();
    this._bindEvents();
  }

  destroy() {
    if (!this.menu) {
      return;
    }
    this.menu.remove();
    this.menu = null;
  }

  _createMenu() {
    this.menu = window.document.createElement("div");
    this.menu.classList.add("collaborative-texts-menu");
    this.menu.innerHTML = `<button class="collaborative-texts-button-suggest">${this.i18n.suggest}</button><button class="collaborative-texts-button-cancel">${this.i18n.cancel}</button>`;
    this.wrapper.after(this.menu);
    this.menu.style.top = `${this.wrapper.getBoundingClientRect().top - this.doc.getBoundingClientRect().top}px`;
  }

  _bindEvents() {
    this.menu.querySelector(".collaborative-texts-button-suggest").addEventListener("click", this._suggest.bind(this));
    this.menu.querySelector(".collaborative-texts-button-cancel").addEventListener("click", this._cancel.bind(this));
  }

  _suggest() {
    console.log("Suggest a change");
    this.selection.showEditor();
    this.destroy();
  }
  
  _cancel() {
    console.log("Cancel suggestion");
    this.destroy();
    this.selection.clear();
  }
}

export default Menu;
