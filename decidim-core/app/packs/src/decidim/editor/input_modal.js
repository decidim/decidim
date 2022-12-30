export default class InputModal {
  constructor({ inputs, removeButton }) {
    const inputId = `inputmodal-${(new Date()).getTime()}`;
    this.element = document.createElement("div");
    this.element.classList.add("reveal");
    this.element.setAttribute("data-reveal", "");

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
          <label for="${inputId}-${name}">${input.label}</label>
          ${inputHTML}
        </div>
      `;
    });

    let buttonsHTML = "";
    buttonsHTML += '<button type="button" class="button mr-xs mb-none" data-action="save">Save</button>';
    if (removeButton) {
      buttonsHTML += '<button type="button" class="button alert mb-none" data-action="remove">Remove</button>';
    } else {
      buttonsHTML += '<button type="button" class="button clear mb-none" data-action="cancel">Cancel</button>';
    }

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

    // Foundation needs jQuery
    $(this.element).on("open.zf.reveal", () => {
      setTimeout(() => this.focusFirstInput(), 0);
    });
    $(this.element).on("closed.zf.reveal", () => {
      setTimeout(() => this.destroy(), 0);
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

      // Foundation needs jQuery
      $(this.element).foundation("open");
    })
  }

  close() {
    // Foundation needs jQuery
    $(this.element).foundation("close");
  }

  destroy() {
    // Foundation needs jQuery
    $(this.element).foundation("_destroy");
    this.element.remove();
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
