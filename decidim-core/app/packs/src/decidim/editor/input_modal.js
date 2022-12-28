export default class InputModal {
  constructor({ inputs, removeButton }) {
    const inputId = `inputmodal-${(new Date()).getTime()}`
    this.element = document.createElement("div");
    this.element.classList.add("reveal");
    this.element.setAttribute("data-reveal", "");

    let inputsHTML = "";
    Object.keys(inputs).forEach((name) => {
      const input = inputs[name];
      inputsHTML += `
        <div data-input="${name}">
          <label for="${inputId}-${name}">${input.label}</label>
          <input id="${inputId}-${name}" type="text">
        </div>
      `;
    });

    let buttonsHTML = "";
    if (removeButton) {
      buttonsHTML += '<button type="button" class="button danger" data-action="remove">Remove</button>';
    } else {
      buttonsHTML += '<button type="button" class="button danger" data-action="cancel">Cancel</button>';
    }
    buttonsHTML += '<button type="button" class="button primary" data-action="save">Save</button>';

    this.element.innerHTML = `
      <div>
        ${inputsHTML}
      </div>
      <div>
        ${buttonsHTML}
      </div>
    `;
    document.body.appendChild(this.element);
    $(this.element).foundation();

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
        const input = wrapper.querySelector("input");
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
    const firstInput = this.element.querySelector("input");
    if (firstInput) {
      firstInput.focus();
    }
  }

  getValue(key = "default") {
    const input = this.element.querySelector(`[data-input="${key}"] input`);
    if (input) {
      return input.value;
    }

    return null;
  }
}
