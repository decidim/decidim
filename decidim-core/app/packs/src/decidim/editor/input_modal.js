import Dialog from "a11y-dialog-component";

import { getDictionary } from "src/decidim/i18n";

export default class InputModal {
  constructor(editor, { inputs, removeButton }) {
    this.editor = editor;
    // The legacy design should not have any elements on the page with the
    // `data-dialog` attribute.
    this.legacyDesign = !document.querySelector("[data-dialog]");
    const inputId = `inputmodal-${(new Date()).getTime()}`;
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

    const i18n = getDictionary("editor.inputModal");

    let buttonsHTML = "";
    if (this.legacyDesign) {
      buttonsHTML += `<button type="button" class="button mr-xs mb-none" data-action="save">${i18n["buttons.save"]}</button>`;
      if (removeButton) {
        buttonsHTML += `<button type="button" class="button alert mb-none" data-action="remove">${i18n["buttons.remove"]}</button>`;
      } else {
        buttonsHTML += `<button type="button" class="button clear mb-none" data-action="cancel">${i18n["buttons.cancel"]}</button>`;
      }
    } else {
      buttonsHTML += `<button type="button" class="button button__sm md:button__lg button__transparent-secondary" data-action="cancel">${i18n["buttons.cancel"]}</button>`;
      if (removeButton) {
        buttonsHTML += `<button type="button" class="button button__sm md:button__lg button__secondary" data-action="remove">${i18n["buttons.remove"]}</button>`;
      } else {
        buttonsHTML += `<button type="button" class="button button__sm md:button__lg button__secondary" data-action="save">${i18n["buttons.save"]}</button>`;
      }
    }

    if (this.legacyDesign) {
      this.element.innerHTML = `
        <div>
          <form>
            ${inputsHTML}
          </form>
        </div>
        <div class="row columns">
          <div class="text-center">
            ${buttonsHTML}
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
        setTimeout(() => this.destroy(), 0);
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
            </form>
          </div>
          <div data-dialog-actions>
            ${buttonsHTML}
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
          setTimeout(() => this.destroy(), 0);
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
        const action = button.dataset.action;

        this.close();
        if (this.callback) {
          this.callback(action);
          this.callback = null;
        }
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
    this.editor.chain().toggleDialog(false).focus(null, { scrollIntoView: false }).run()

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

  focusFirstInput() {
    const firstInput = this.element.querySelector("input, select");
    if (firstInput) {
      firstInput.focus();
    }
  }

  getValue(key = "default") {
    const wrapper = this.element.querySelector(`[data-input="${key}"]`);
    const input = wrapper.querySelector("input, select");
    if (input) {
      return input.value;
    }

    return null;
  }
}
