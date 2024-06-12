/**
 * This script modifies the behavior of Abide form validation to address the issue of form validation errors
 * appearing prematurely in input fields.
 *
 * The primary goal is to hide error messages until the input field loses focus.
 */

class AbideFormValidatorFixer {
  initialize() {
    const forms = document.querySelectorAll("main [data-live-validate='true']");

    forms.forEach((form) => {
      if (this.isElementVisible(form)) {
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
      const errorElement = input.closest("label")?.querySelector(".form-error") || input.parentElement.querySelector(".form-error");
      if (!errorElement) {
        return;
      }
      form.removeAttribute("data-live-validate");
      input.addEventListener("input", this.hideErrorElement.bind(this, errorElement));
    });
  }

  hideErrorElement(errorElement) {
    errorElement.classList.remove("is-visible");
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const validatorFixer = new AbideFormValidatorFixer();
  validatorFixer.initialize();
});
