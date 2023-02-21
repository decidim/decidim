import Dialog from "a11y-dialog-component";

import { getDictionary } from "src/decidim/i18n";
import { uniqueId } from "src/decidim/editor/common/helpers";

export default class InputDialog {
  constructor(editor, { inputs }) {
    this.editor = editor;
    // The legacy design should not have any elements on the page with the
    // `data-dialog` attribute.
    this.legacyDesign = !document.querySelector("[data-dialog]");
    const inputId = uniqueId("inputdialog");
    this.element = document.createElement("div");
    if (this.legacyDesign) {
      this.element.classList.add("reveal");
      this.element.setAttribute("data-reveal", "");
    } else {
      this.element.dataset.dialog = `${Math.random().toString(36).slice(2)}`;
    }

    let inputsHTML = "";
    Object.keys(inputs).forEach((name) => {
      const input = inputs[name];
      let inputHTML = "";
      if (input.type === "select") {
        const optionsHTML = input.options.map((opt) => `<option value="${opt.value}">${opt.label}</option>`)
        inputHTML = `<select id="${inputId}-${name}">${optionsHTML}</select>`;
      } else {
        inputHTML = `<input id="${inputId}-${name}" type="${input.type || "text"}">`;
      }

      inputsHTML += `
        <div data-input="${name}">
          <label>
            ${input.label}
            ${inputHTML}
          </label>
        </div>
      `;
    });

    const i18n = getDictionary("editor.inputDialog");

    if (this.legacyDesign) {
      this.element.innerHTML = `
        <div>
          <form>
            ${inputsHTML}
            <input type="submit" hidden>
          </form>
        </div>
        <div class="row columns">
          <div class="text-center">
            <button type="button" class="button mr-xs mb-none" data-action="save">${i18n["buttons.save"]}</button>
            <button type="button" class="button clear mb-none" data-action="cancel">${i18n["buttons.cancel"]}</button>
          </div>
        </div>
      `;

      document.body.appendChild(this.element);
      $(this.element).foundation();

      // Foundation needs jQuery
      $(this.element).on("open.zf.reveal", () => {
        setTimeout(() => this.focusFirstInput(), 0);
      });
      $(this.element).on("closed.zf.reveal", () => {
        setTimeout(() => this.handleClose(), 0);
      });
    } else {
      const uniq = this.element.dataset.dialog;
      this.element.innerHTML = `
        <div id="${uniq}-content">
          <button type="button" data-dialog-close="${uniq}" data-dialog-closable="" aria-label="${i18n.close}">&times</button>
          <div data-dialog-container>
            <form>
              <div class="form__wrapper">
                ${inputsHTML}
              </div>
              <input type="submit" hidden>
            </form>
          </div>
          <div data-dialog-actions>
            <button type="button" class="button button__sm md:button__lg button__transparent-secondary" data-action="cancel">${i18n["buttons.cancel"]}</button>
            <button type="button" class="button button__sm md:button__lg button__secondary" data-action="save">${i18n["buttons.save"]}</button>
          </div>
        </div>
      `;
      document.body.appendChild(this.element);

      this.dialog = new Dialog(`[data-dialog="${uniq}"]`, {
        // openingSelector: `[data-dialog-open="${uniq}"]`,
        closingSelector: `[data-dialog-close="${uniq}"]`,
        backdropSelector: `[data-dialog="${uniq}"]`,
        enableAutoFocus: false,
        onOpen: () => {
          setTimeout(() => this.focusFirstInput(), 0);
        },
        onClose: () => {
          setTimeout(() => this.handleClose(), 0);
        }
      });
    }

    this.element.querySelector("form").addEventListener("submit", (ev) => {
      ev.preventDefault();

      const btn = this.element.querySelector("button[data-action='save']");
      btn.dispatchEvent(new Event("click"));
    });
    this.element.querySelectorAll("button[data-action]").forEach((button) => {
      button.addEventListener("click", (ev) => {
        ev.preventDefault();
        this.action = button.dataset.action;
        this.close();
      });
    });
  }

  toggle(currentValues = {}) {
    return new Promise((resolve) => {
      this.element.querySelectorAll("[data-input]").forEach((wrapper) => {
        const input = wrapper.querySelector("input, select");
        const currentValue = currentValues[wrapper.dataset.input];
        if (currentValue) {
          input.value = currentValue;
        } else {
          input.value = "";
        }
      });

      this.callback = resolve;
      this.action = null;

      this.editor.commands.toggleDialog(true);

      if (this.legacyDesign) {
        // Foundation needs jQuery
        $(this.element).foundation("open");
      } else {
        this.dialog.open();
      }
    })
  }

  close() {
    if (this.legacyDesign) {
      // Foundation needs jQuery
      $(this.element).foundation("close");
    } else {
      this.dialog.close();
    }
  }

  destroy() {
    if (this.legacyDesign) {
      // Foundation needs jQuery
      $(this.element).foundation("_destroy");
      this.element.remove();
    } else {
      this.dialog.destroy();
      this.element.remove();
      Reflect.deleteProperty(this, "dialog");
    }
  }

  /**
   * This is fired when the dialog is actually closed. The `close()` method only
   * initiates the closing of the dialog.
   *
   * @returns {void}
   */
  handleClose() {
    this.editor.chain().toggleDialog(false).focus(null, { scrollIntoView: false }).run();

    if (this.callback) {
      this.callback(this.action);
      this.callback = null;
    }
    if (this.action) {
      this.action = null;
    }

    this.destroy();
  }

  focusFirstInput() {
    const firstInput = this.element.querySelector("input, select");
    if (firstInput) {
      firstInput.focus();
    }
  }

  getValue(key = "default") {
    const wrapper = this.element.querySelector(`[data-input="${key}"]`);
    if (!wrapper) {
      return null;
    }

    const input = wrapper.querySelector("input, select");
    if (input) {
      return input.value;
    }

    return null;
  }
}
