/**
 * This script modifies the behavior of Abide form validation to address the issue of form validation errors
 * appearing prematurely in input fields.
 *
 * The primary goal is to hide error messages until the input field loses focus.
 *
 * It also patches the checkbox group validation to avoid browser freezes in
 * very large checkbox groups.
 */

class AbideFormValidatorFixer {
  initialize() {
    this.patchCheckboxValidation();

    const forms = document.querySelectorAll("main [data-live-validate='true']");

    forms.forEach((form) => {
      if (this.isElementVisible(form)) {
        this.setupForm(form);
      }
    });
  }

  patchCheckboxValidation() {
    const abidePrototype = window.Foundation?.Abide?.prototype;

    if (!abidePrototype || abidePrototype.validateCheckbox?.__decidimPatched) {
      return;
    }

    abidePrototype.validateCheckbox = function(groupName) {
      const $group = this.$element.find(`:checkbox[name="${groupName}"]`);
      let valid = false;
      let required = false;
      let minRequired = 1;
      let checked = 0;

      $group.each((_i, element) => {
        if ($(element).attr("required")) {
          required = true;
        }
      });

      if (!required) {
        valid = true;
      }

      if (!valid) {
        $group.each((_i, element) => {
          if ($(element).prop("checked")) {
            checked += 1;
          }

          if (typeof $(element).attr("data-min-required") !== "undefined") {
            minRequired = parseInt($(element).attr("data-min-required"), 10);
          }
        });

        if (checked >= minRequired) {
          valid = true;
        }
      }

      if (this.initialized !== true && minRequired > 1) {
        return true;
      }

      if (valid) {
        this.removeCheckboxErrorClasses(groupName);
      } else {
        $group.each((_i, element) => {
          this.addErrorClasses($(element), ["required"]);
        });
      }

      return valid;
    };

    abidePrototype.validateCheckbox.__decidimPatched = true;
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

export default AbideFormValidatorFixer;
