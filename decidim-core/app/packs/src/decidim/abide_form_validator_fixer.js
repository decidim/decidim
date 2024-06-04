document.addEventListener("DOMContentLoaded", () => {
  const validatorFixer = new AbideFormValidatorFixer();
  validatorFixer.initialize();
});

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
