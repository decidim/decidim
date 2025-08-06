const DEFAULT_MESSAGES = {
  correctErrors: "There are errors on the form, please correct them."
};
let MESSAGES = DEFAULT_MESSAGES;

export default class FormValidator {
  static configureMessages(messages) {
    MESSAGES = { ...DEFAULT_MESSAGES, ...messages };
  }

  constructor(formElement, validationOptions = {}) {
    // Handle both CSS selectors and DOM elements
    if (typeof formElement === "string") {
      this.formElement = document.querySelector(formElement);
      if (!this.formElement) {
        throw new Error("Form element not found");
      }
    } else {
      this.formElement = formElement;
    }

    this.validationOptions = {
      validateOn: "fieldChange",
      inputErrorClass: "is-invalid-input",
      formErrorClass: "is-visible",
      ...validationOptions
    };

    this.inputElements = this.formElement.querySelectorAll("input, select, textarea");
    this.validationEnabled = true;
  }

  handleError() {
    this.announceFormError();

    const firstInvalidElement = this.formElement.querySelector(".is-invalid-input");
    if (firstInvalidElement) {
      firstInvalidElement.focus();
    }
  }

  /**
   * This announces immediately to the screen reader that there are errors on
   * the form that need to be fixed. Does not work on all screen readers but
   * works e.g. in Windows+Firefox+NVDA and macOS+Safari+VoiceOver
   * combinations.
   *
   * @returns {undefined}
   */
  announceFormError() {
    this.announceFormErrorForScreenReader();
  }

  announceFormErrorForScreenReader() {

    // Pure DOM implementation for non-jQuery environments
    let announceElement = this.formElement.querySelector(".sr-announce");
    if (announceElement) {
      announceElement.remove();
    }
    announceElement = document.createElement("div");
    announceElement.className = "sr-announce sr-only";
    announceElement.setAttribute("aria-live", "assertive");
    this.formElement.prepend(announceElement);

    setTimeout(() => {
      announceElement.textContent = MESSAGES.correctErrors;
    }, 100);
  }

  validateRadioGroup(groupName) {
    const radios = this.formElement.querySelectorAll(`input[name="${groupName}"][type="radio"]`);
    const checkedRadios = Array.from(radios).filter((radio) => radio.checked);

    if (radios.length === 0) {
      return true;
    }

    // Check if any radio in the group is required
    const hasRequired = Array.from(radios).some((radio) => radio.required);
    if (!hasRequired) {
      return true;
    }

    // For radio groups, we need at least one selected if any in the group is required
    const isValid = checkedRadios.length > 0;

    // Add/remove error classes for all radios in the group
    radios.forEach((radio) => {
      if (isValid) {
        this.removeErrorClasses(radio);
      } else {
        this.addErrorClasses(radio);
      }
    });

    return isValid;
  }

  validateCheckboxGroup(groupName) {
    const checkboxes = this.formElement.querySelectorAll(`input[name="${groupName}"][type="checkbox"]`);
    const checkedBoxes = Array.from(checkboxes).filter((cb) => cb.checked);

    if (checkboxes.length === 0) {
      return true;
    }

    // Check if any checkbox in the group is required
    const hasRequired = Array.from(checkboxes).some((cb) => cb.required);
    if (!hasRequired) {
      return true;
    }

    // Check minimum required
    const minRequired = checkboxes[0].getAttribute("data-min-required");
    const minCount = minRequired
      ? parseInt(minRequired, 10)
      : 1;

    const isValid = checkedBoxes.length >= minCount;

    // Add/remove error classes for all checkboxes in the group
    checkboxes.forEach((cb) => {
      if (isValid) {
        this.removeErrorClasses(cb);
      } else {
        this.addErrorClasses(cb);
      }
    });

    return isValid;
  }

  // eslint-disable-next-line complexity
  validateSingleInput(input) {
    if (!input || input.disabled) {
      return true;
    }

    // Skip radio buttons - they are handled by validateRadioGroup
    if (input.type === "radio") {
      // Let validateRadioGroup handle this
      return true;
    }

    // Handle checkboxes that are part of a group
    if (input.type === "checkbox" && input.name) {
      const checkboxGroup = this.formElement.querySelectorAll(`input[name="${input.name}"][type="checkbox"]`);
      if (checkboxGroup.length > 1) {
        // Let validateCheckboxGroup handle this
        return true;
      }
    }

    // Basic validation for other input types
    if (input.required && !input.value.trim()) {
      this.addErrorClasses(input);
      return false;
    }

    if (input.type === "email" && input.value) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(input.value)) {
        this.addErrorClasses(input);
        return false;
      }
    }

    // Single checkbox validation
    if (input.type === "checkbox" && input.required && !input.checked) {
      this.addErrorClasses(input);
      return false;
    }

    // Select validation
    if (input.tagName === "SELECT" && input.required && (!input.value || input.value === "")) {
      this.addErrorClasses(input);
      return false;
    }

    // Textarea validation
    if (input.tagName === "TEXTAREA" && input.required && !input.value.trim()) {
      this.addErrorClasses(input);
      return false;
    }

    this.removeErrorClasses(input);
    return true;
  }

  validateEntireForm() {
    let isValid = true;

    // Validate individual inputs (excluding radios and multi-checkboxes)
    this.inputElements.forEach((input) => {
      if (input.type !== "radio") {
        const inputValid = this.validateSingleInput(input);
        if (!inputValid) {
          isValid = false;
        }
      }
    });

    // Check radio groups
    const radioGroups = new Set();
    this.formElement.querySelectorAll('input[type="radio"]').forEach((radio) => {
      if (radio.name) {
        radioGroups.add(radio.name);
      }
    });

    radioGroups.forEach((groupName) => {
      const radioValid = this.validateRadioGroup(groupName);
      if (!radioValid) {
        isValid = false;
      }
    });

    // Check checkbox groups
    const checkboxGroups = new Set();
    this.formElement.querySelectorAll('input[type="checkbox"]').forEach((cb) => {
      if (cb.name) {
        const groupCheckboxes = this.formElement.querySelectorAll(`input[name="${cb.name}"][type="checkbox"]`);
        if (groupCheckboxes.length > 1) {
          checkboxGroups.add(cb.name);
        }
      }
    });

    checkboxGroups.forEach((groupName) => {
      const checkboxValid = this.validateCheckboxGroup(groupName);
      if (!checkboxValid) {
        isValid = false;
      }
    });

    return isValid;
  }

  addErrorClasses(input) {
    input.classList.add(this.validationOptions.inputErrorClass);
    input.setAttribute("aria-invalid", "true");
  }

  removeErrorClasses(input) {
    input.classList.remove(this.validationOptions.inputErrorClass);
    input.removeAttribute("aria-invalid");
  }

  destroyValidator() {
    // Cleanup method
    this.inputElements.forEach((input) => {
      this.removeErrorClasses(input);
    });
  }
}
