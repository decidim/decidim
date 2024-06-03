document.addEventListener("DOMContentLoaded", () => {
  new AbideFormValidatorFixer().initialize();
});

class AbideFormValidatorFixer {
  constructor() {
    this.initialize();
  }

  initialize() {
    const forms = document.querySelectorAll("[data-live-validate='true']");

    forms.forEach(form => {
      if (this.isElementVisible(form)) {
        form.removeAttribute("data-live-validate");
        this.setupForm(form);
      }
    });
  }

  isElementVisible(element) {
    return element.offsetParent !== null && getComputedStyle(element).display !== "none";
  }

  setupForm(form) {
    const inputs = form.querySelectorAll("input");

    inputs.forEach((input) => {
      const errorElement = input.querySelector(".form-error");

      if (!errorElement) {
        return;
      }

      input.addEventListener("focus", () => {
        this.hideError(errorElement);
      });

      input.addEventListener("blur", () => {
        this.validateInput(input, errorElement);
      });

      input.addEventListener("input", () => {
        this.hideError(errorElement);
      });
    });
  }

  hideError(errorElement) {
    if (errorElement) {
      errorElement.classList.remove("is-visible");
    }
  }

  validateInput(input, errorElement) {
    if (input.value.trim() === "") {
      errorElement.classList.add("is-visible");
    } else {
      this.hideError(errorElement);
    }
  }
}
