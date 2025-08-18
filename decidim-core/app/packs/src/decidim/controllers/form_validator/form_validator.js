/* eslint max-lines: ["error", 840] */
import { getDictionary } from "src/decidim/i18n";

/**
 * FormValidator class provides comprehensive form validation functionality
 * with accessibility support and customizable validation rules
 */
class FormValidator {

  /**
   * Constructor initializes the FormValidator with form element and options
   * @param {HTMLElement|string} formElement - Form element or CSS selector
   * @param {Object} validationOptions - Configuration options for validation
   */
  constructor(formElement, validationOptions = {}) {
    this.element = typeof formElement === "string"
      ? document.querySelector(formElement)
      : formElement;

    if (!this.element) {
      throw new Error("Form element not found");
    }

    this.validationOptions = {
      validateOn: "fieldChange",
      liveValidate: false,
      validateOnBlur: true,
      labelErrorClass: "is-invalid-label",
      inputErrorClass: "is-invalid-input",
      formErrorClass: "is-visible",
      formErrorSelector: ".form-error",
      a11yAttributes: true,
      a11yErrorLevel: "assertive",
      showErrorsWhileFocused: false,
      patterns: {
        alpha: /^[a-zA-Z]+$/,
        // eslint-disable-next-line camelcase
        alpha_numeric: /^[a-zA-Z0-9]+$/,
        integer: /^[-+]?\d+$/,
        number: /^[-+]?\d*(?:[.,]\d+)?$/,
        email: /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/,
        url: /^https?:\/\/(?:www\.)?[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*(?:\/[^\s]*)?$/i,
        time: /^(0[0-9]|1[0-9]|2[0-3])(:[0-5][0-9]){2}$/,
        color: /^#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$/
      },
      validators: {
        equalTo: (element) => {
          const targetIdentifier = element.getAttribute("data-equalto");
          const targetElement = document.getElementById(targetIdentifier);
          return targetElement
            ? targetElement.value === element.value
            : true;
        }
      },
      ...validationOptions
    };

    this.enableValidation()
    this.formnovalidate = null;
    this.validatorInitialized = false;

    this.initializeValidator();
    this.setupLegacyCompatibility();
  }

  /**
   * Add legacy compatibility for the original FormValidator behavior
   * @returns {void}
   */
  setupLegacyCompatibility() {
    // Listen for the original form-error.decidim event
    this.element.addEventListener("form-error.decidim", () => {
      this.handleFormError();
    });

    // Trigger the legacy event when form validation fails
    this.element.addEventListener("forminvalid.formvalidator", () => {
      this.element.dispatchEvent(new CustomEvent("form-error.decidim"));
    });
  }

  /**
   * Handle form error by announcing it and focusing first invalid input
   * @returns {void}
   */
  handleFormError() {
    this.announceFormErrorForScreenReader();

    // Focus on the first invalid input
    const firstInvalidInput = this.element.querySelector(".is-invalid-input");
    if (firstInvalidInput) {
      firstInvalidInput.focus();
    }
  }

  /**
   * This announces immediately to the screen reader that there are errors on
   * the form that need to be fixed. Does not work on all screen readers but
   * works for example in Windows+Firefox+NVDA and macOS+Safari+VoiceOver
   * combinations.
   * @returns {undefined}
   */
  announceFormErrorForScreenReader() {
    let announceElement = this.element.querySelector(".sr-announce");

    if (announceElement) {
      announceElement.remove();
    }

    announceElement = document.createElement("div");
    announceElement.className = "sr-announce sr-only";
    announceElement.setAttribute("aria-live", "assertive");
    this.element.prepend(announceElement);

    setTimeout(() => {
      announceElement.textContent = getDictionary("forms.correct_errors");
    }, 100);
  }

  /**
   * Initialize the validator by finding form elements and setting up events
   * @returns {void}
   */
  initializeValidator() {
    this.inputElements = Array.from(this.element.querySelectorAll('input:not([type="submit"]), textarea, select'));
    this.submitElements = Array.from(this.element.querySelectorAll('[type="submit"]'));

    if (this.validationOptions.a11yAttributes) {
      this.inputElements.forEach((inputElement) => this.addAccessibilityAttributes(inputElement));
      this.element.querySelectorAll("[data-form-error]").forEach((errorElement) => this.addGlobalErrorAccessibilityAttributes(errorElement));
    }

    this.bindFormEvents();
  }

  /**
   * Bind all necessary events for form validation
   * @returns {void}
   */
  bindFormEvents() {
    this.element.addEventListener("submit", (submitEvent) => {
      if (!this.validateEntireForm()) {
        submitEvent.preventDefault();
        return false;
      }
      return true;
    });

    this.element.addEventListener("reset", () => {
      this.resetFormValidation();
    });

    this.submitElements.forEach((submitElement) => {
      submitElement.addEventListener("click", (clickEvent) => {
        this.formnovalidate = clickEvent.target.getAttribute("formnovalidate") !== null;
      });

      submitElement.addEventListener("keydown", (keyEvent) => {
        if (keyEvent.key === " " || keyEvent.key === "Enter") {
          this.formnovalidate = keyEvent.target.getAttribute("formnovalidate") !== null;
        }
      });
    });

    this.inputElements.forEach((inputElement) => {
      if (this.validationOptions.validateOn === "fieldChange") {
        inputElement.addEventListener("change", (changeEvent) => {
          this.validateSingleInput(changeEvent.target);
        });
      }

      if (this.validationOptions.liveValidate) {
        inputElement.addEventListener("input", (inputEvent) => {
          this.validateSingleInput(inputEvent.target);
        });
      }

      if (this.validationOptions.validateOnBlur) {
        inputElement.addEventListener("blur", (blurEvent) => {

          this.validateSingleInput(blurEvent.target);
        });
      }
    });
  }

  /**
   * Validate a single input element
   * @param {HTMLElement} inputElement - The input element to validate
   * @returns {boolean} - True if valid, false otherwise
   */
  validateSingleInput(inputElement) {
    if (this.isValidationCurrentlyDisabled()) {
      return true;
    }
    if (this.shouldSkipInputValidation(inputElement)) {
      return true;
    }

    const failedValidatorNames = [];
    let manageErrorClasses = true;

    if (!this.checkIfInputRequired(inputElement)) {
      failedValidatorNames.push("required");
    }

    // Type-specific validation
    switch (inputElement.type) {
    case "radio":
      if (!this.validateRadioGroup(inputElement.name)) {
        failedValidatorNames.push("required");
      }
      break;
    case "checkbox":
      if (!this.validateCheckboxGroup(inputElement.name)) {
        failedValidatorNames.push("required");
      }
      manageErrorClasses = false;
      break;
    case "select":
    case "select-one":
    case "select-multiple":
      break;
    default:
      if (!this.validateTextInput(inputElement)) {
        failedValidatorNames.push("pattern");
      }
    }

    // Custom validators
    const validatorAttribute = inputElement.getAttribute("data-validator");
    if (validatorAttribute) {
      const isRequiredInput = inputElement.hasAttribute("required");
      validatorAttribute.split(" ").forEach((validatorName) => {
        if (this.validationOptions.validators[validatorName] && !this.validationOptions.validators[validatorName](inputElement, isRequiredInput, inputElement.parentElement)) {
          failedValidatorNames.push(validatorName);
        }
      });
    }

    const equalToAttribute = inputElement.getAttribute("data-equalto");
    if (equalToAttribute && !this.validationOptions.validators.equalTo(inputElement)) {
      failedValidatorNames.push("equalTo");
    }

    const inputIsValid = failedValidatorNames.length === 0;

    if (inputIsValid && inputElement.id) {
      const dependentElements = this.element.querySelectorAll(`[data-equalto="${inputElement.id}"]`);
      dependentElements.forEach((dependentElement) => {
        if (dependentElement.value) {
          this.validateSingleInput(dependentElement);
        }
      });
    }

    if (manageErrorClasses) {
      if (inputIsValid) {
        this.removeInputErrorClasses(inputElement);
      } else {
        this.addInputErrorClasses(inputElement, failedValidatorNames);
      }
    }

    // Trigger events
    const eventName = inputIsValid
      ? "valid"
      : "invalid";
    inputElement.dispatchEvent(new CustomEvent(`${eventName}.formvalidator`, {
      detail: { input: inputElement, failedValidators: failedValidatorNames }
    }));

    return inputIsValid;
  }

  /**
   * Validate the entire form
   * @returns {boolean} - True if entire form is valid, false otherwise
   */
  validateEntireForm() {
    if (this.isValidationCurrentlyDisabled()) {
      this.formnovalidate = null;
      return true;
    }

    if (!this.validatorInitialized) {
      this.validatorInitialized = true;
    }

    const validationResults = [];
    const processedCheckboxGroups = new Set();
    const processedRadioGroups = new Set();

    this.inputElements.forEach((inputElement) => {
      if (inputElement.type === "checkbox") {
        if (processedCheckboxGroups.has(inputElement.name)) {
          return;
        }
        processedCheckboxGroups.add(inputElement.name);
      }

      if (inputElement.type === "radio") {
        if (processedRadioGroups.has(inputElement.name)) {
          return;
        }
        processedRadioGroups.add(inputElement.name);
      }

      validationResults.push(this.validateSingleInput(inputElement));
    });

    const formIsValid = !validationResults.includes(false);

    this.element.querySelectorAll("[data-form-error]").forEach((errorElement) => {
      if (this.validationOptions.a11yAttributes) {
        this.addGlobalErrorAccessibilityAttributes(errorElement);
      }
      errorElement.style.display = formIsValid
        ? "none"
        : "block";
    });

    const eventName = formIsValid
      ? "formvalid"
      : "forminvalid";
    this.element.dispatchEvent(new CustomEvent(`${eventName}.formvalidator`, {
      detail: { form: this.element, isValid: formIsValid }
    }));

    return formIsValid;
  }

  /**
   * Validate text input against pattern
   * @param {HTMLElement} inputElement - The input element to validate
   * @param {string|null} patternOverride - Optional pattern override
   * @returns {boolean} - True if valid, false otherwise
   */
  validateTextInput(inputElement, patternOverride = null) {
    const pattern = patternOverride || inputElement.getAttribute("data-pattern") || inputElement.getAttribute("pattern") || inputElement.type;
    const inputText = inputElement.value;

    if (!inputText.length) {
      return true;
    }

    if (this.validationOptions.patterns[pattern]) {
      return this.validationOptions.patterns[pattern].test(inputText);
    } else if (pattern !== inputElement.type) {
      return new RegExp(pattern).test(inputText);
    }

    return true;
  }

  /**
   * Validate radio button group
   * @param {string} groupName - Name attribute of the radio group
   * @returns {boolean} - True if valid, false otherwise
   */
  validateRadioGroup(groupName) {
    const radioGroup = this.element.querySelectorAll(`input[type="radio"][name="${groupName}"]`);
    let isRequired = false;
    let checkedCount = 0;

    radioGroup.forEach((radioElement) => {
      if (radioElement.hasAttribute("required")) {
        isRequired = true;
      }
    });

    if (!isRequired) {
      return true;
    }

    radioGroup.forEach((radioElement) => {
      if (radioElement.checked) {
        checkedCount += 1;
      }
    });

    return checkedCount > 0;
  }

  /**
   * Validate checkbox group
   * @param {string} groupName - Name attribute of the checkbox group
   * @returns {boolean} - True if valid, false otherwise
   */
  validateCheckboxGroup(groupName) {
    const checkboxGroup = this.element.querySelectorAll(`input[type="checkbox"][name="${groupName}"]`);
    let isRequired = false;
    let isValid = false;
    let minimumRequired = 1;
    let checkedCount = 0;

    checkboxGroup.forEach((checkboxElement) => {
      if (checkboxElement.hasAttribute("required")) {
        isRequired = true;
      }
      if (checkboxElement.checked) {
        checkedCount += 1;
      }
      const minimumRequiredAttribute = checkboxElement.getAttribute("data-min-required");
      if (minimumRequiredAttribute) {
        minimumRequired = parseInt(minimumRequiredAttribute, 10);
      }
    });

    if (!isRequired) {
      isValid = true;
    }
    if (!isValid && checkedCount >= minimumRequired) {
      isValid = true;
    }

    if (!this.validatorInitialized && minimumRequired > 1) {
      return true;
    }

    checkboxGroup.forEach((checkboxElement) => {
      if (isValid) {
        this.removeInputErrorClasses(checkboxElement);
      } else {
        this.addInputErrorClasses(checkboxElement, ["required"]);
      }
    });

    return isValid;
  }

  /**
   * Check if input is required and has valid value
   * @param {HTMLElement} inputElement - The input element to check
   * @returns {boolean} - True if requirement is satisfied, false otherwise
   */
  checkIfInputRequired(inputElement) {
    if (!inputElement.hasAttribute("required")) {
      return true;
    }

    switch (inputElement.type) {
    case "checkbox":
      return inputElement.checked;
    case "radio":
      return inputElement.checked;
    case "select":
    case "select-one":
    case "select-multiple":
      // eslint-disable-next-line no-case-declarations
      const selectedOption = inputElement.querySelector("option:checked") || inputElement.selectedOptions[0];
      return selectedOption && selectedOption.value;
    default:
      return inputElement.value && inputElement.value.trim().length > 0;
    }
  }

  /**
   * Add error classes and accessibility attributes to input
   * @param {HTMLElement} inputElement - The input element to add error classes to
   * @param {Array} failedValidatorNames - Array of failed validator names
   * @returns {void}
   */
  addInputErrorClasses(inputElement, failedValidatorNames = []) {
    // Skip showing errors if the input is currently focused
    if (!this.validationOptions.showErrorsWhileFocused && document.activeElement === inputElement) {
      return;
    }

    const labelElement = this.findInputLabel(inputElement);
    const formErrorElements = this.findFormErrorElements(inputElement, failedValidatorNames);

    if (labelElement) {
      labelElement.classList.add(this.validationOptions.labelErrorClass);
    }

    if (formErrorElements.length > 0) {
      formErrorElements.forEach((errorElement) => errorElement.classList.add(this.validationOptions.formErrorClass));
    }

    inputElement.classList.add(this.validationOptions.inputErrorClass);
    inputElement.setAttribute("data-invalid", "");
    inputElement.setAttribute("aria-invalid", "true");

    const visibleErrorElements = formErrorElements.filter((errorElement) =>
      getComputedStyle(errorElement).display !== "none"
    );
    if (visibleErrorElements.length > 0) {
      this.addAccessibilityErrorDescribe(inputElement, visibleErrorElements[0]);
    }
  }

  /**
   * Remove error classes and accessibility attributes from input
   * @param {HTMLElement} inputElement - The input element to remove error classes from
   * @returns {void}
   */
  // eslint-disable-next-line consistent-return
  removeInputErrorClasses(inputElement) {
    // Handle radio and checkbox groups
    if (inputElement.type === "radio") {
      return this.removeRadioGroupErrorClasses(inputElement.name);
    } else if (inputElement.type === "checkbox") {
      return this.removeCheckboxGroupErrorClasses(inputElement.name);
    }

    const labelElement = this.findInputLabel(inputElement);
    const formErrorElements = this.findFormErrorElements(inputElement);

    if (labelElement) {
      labelElement.classList.remove(this.validationOptions.labelErrorClass);
    }

    formErrorElements.forEach((errorElement) => {
      errorElement.classList.remove(this.validationOptions.formErrorClass);
    });

    inputElement.classList.remove(this.validationOptions.inputErrorClass);
    inputElement.removeAttribute("data-invalid");
    inputElement.removeAttribute("aria-invalid");

    if (inputElement.hasAttribute("aria-describedby")) {
      inputElement.removeAttribute("aria-describedby");
    }
  }

  /**
   * Remove error classes from radio button group
   * @param {string} groupName - Name attribute of the radio group
   * @returns {void}
   */
  removeRadioGroupErrorClasses(groupName) {
    const radioGroup = this.element.querySelectorAll(`input[type="radio"][name="${groupName}"]`);
    radioGroup.forEach((radioElement) => {
      const labelElement = this.findInputLabel(radioElement);
      const formErrorElements = this.findFormErrorElements(radioElement);

      if (labelElement) {
        labelElement.classList.remove(this.validationOptions.labelErrorClass);
      }
      formErrorElements.forEach((errorElement) => errorElement.classList.remove(this.validationOptions.formErrorClass));

      radioElement.classList.remove(this.validationOptions.inputErrorClass);
      radioElement.removeAttribute("data-invalid");
      radioElement.removeAttribute("aria-invalid");
    });
  }

  /**
   * Remove error classes from checkbox group
   * @param {string} groupName - Name attribute of the checkbox group
   * @returns {void}
   */
  removeCheckboxGroupErrorClasses(groupName) {
    const checkboxGroup = this.element.querySelectorAll(`input[type="checkbox"][name="${groupName}"]`);
    checkboxGroup.forEach((checkboxElement) => {
      const labelElement = this.findInputLabel(checkboxElement);
      const formErrorElements = this.findFormErrorElements(checkboxElement);

      if (labelElement) {
        labelElement.classList.remove(this.validationOptions.labelErrorClass);
      }
      formErrorElements.forEach((errorElement) => errorElement.classList.remove(this.validationOptions.formErrorClass));

      checkboxElement.classList.remove(this.validationOptions.inputErrorClass);
      checkboxElement.removeAttribute("data-invalid");
      checkboxElement.removeAttribute("aria-invalid");
    });
  }

  /**
   * Find the label element associated with an input
   * @param {HTMLElement} inputElement - The input element
   * @returns {HTMLElement|null} - The associated label element or null
   */
  findInputLabel(inputElement) {
    if (inputElement.id) {
      const labelElement = this.element.querySelector(`label[for="${inputElement.id}"]`);
      if (labelElement) {
        return labelElement;
      }
    }
    return inputElement.closest("label");
  }

  /**
   * Find form error elements associated with an input
   * @param {HTMLElement} inputElement - The input element
   * @param {Array} failedValidatorNames - Array of failed validator names
   * @returns {Array} - Array of error elements
   */
  findFormErrorElements(inputElement, failedValidatorNames = []) {
    const errorElements = [];
    const inputIdentifier = inputElement.id;

    const siblingErrorElements = Array.from(inputElement.parentElement.querySelectorAll(this.validationOptions.formErrorSelector));
    errorElements.push(...siblingErrorElements);

    if (inputIdentifier) {
      const referencedErrorElements = Array.from(this.element.querySelectorAll(`[data-form-error-for="${inputIdentifier}"]`));
      errorElements.push(...referencedErrorElements);
    }

    if (failedValidatorNames.length > 0) {
      const generalErrorElements = errorElements.filter((errorElement) => !errorElement.hasAttribute("data-form-error-on"));
      const specificErrorElements = [];

      failedValidatorNames.forEach((validatorName) => {
        const validatorErrorElements = Array.from(this.element.querySelectorAll(`[data-form-error-on="${validatorName}"]`));
        specificErrorElements.push(...validatorErrorElements);
      });

      return [...generalErrorElements, ...specificErrorElements];
    }

    return errorElements;
  }

  /**
   * Add accessibility attributes to input element
   * @param {HTMLElement} inputElement - The input element
   * @returns {void}
   */
  addAccessibilityAttributes(inputElement) {
    const errorElements = this.findFormErrorElements(inputElement);
    if (errorElements.length === 0) {
      return;
    }

    const visibleErrorElement = errorElements.find((errorElement) => getComputedStyle(errorElement).display !== "none");
    if (visibleErrorElement) {
      this.addAccessibilityErrorDescribe(inputElement, visibleErrorElement);
    }

    if (!inputElement.id) {
      inputElement.id = this.generateUniqueIdentifier("input");
    }

    errorElements.forEach((errorElement) => {
      if (!errorElement.hasAttribute("role")) {
        errorElement.setAttribute("role", "alert");
      }
    });
  }

  /**
   * Add aria-describedby attribute linking input to error element
   * @param {HTMLElement} inputElement - The input element
   * @param {HTMLElement} errorElement - The error element
   * @returns {void}
   */
  addAccessibilityErrorDescribe(inputElement, errorElement) {
    if (inputElement.hasAttribute("aria-describedby")) {
      return;
    }

    if (!errorElement.id) {
      errorElement.id = this.generateUniqueIdentifier("error");
    }

    inputElement.setAttribute("aria-describedby", errorElement.id);
  }

  /**
   * Add global error accessibility attributes
   * @param {HTMLElement} errorElement - The error element
   * @returns {void}
   */
  addGlobalErrorAccessibilityAttributes(errorElement) {
    if (!errorElement.hasAttribute("aria-live")) {
      errorElement.setAttribute("aria-live", this.validationOptions.a11yErrorLevel);
    }
  }

  /**
   * Reset form validation state and remove all error indicators
   * @returns {void}
   */
  resetFormValidation() {
    this.element.querySelectorAll(`.${this.validationOptions.labelErrorClass}`).forEach((element) => {
      element.classList.remove(this.validationOptions.labelErrorClass);
    });

    this.element.querySelectorAll(`.${this.validationOptions.inputErrorClass}`).forEach((element) => {
      element.classList.remove(this.validationOptions.inputErrorClass);
      element.removeAttribute("data-invalid");
      element.removeAttribute("aria-invalid");
      element.removeAttribute("aria-describedby");
    });

    this.element.querySelectorAll(`${this.validationOptions.formErrorSelector}.${this.validationOptions.formErrorClass}`).forEach((element) => {
      element.classList.remove(this.validationOptions.formErrorClass);
    });

    this.element.querySelectorAll("[data-form-error]").forEach((element) => {
      element.style.display = "none";
    });

    this.inputElements.forEach((inputElement) => {
      if (!["button", "submit", "reset", "hidden"].includes(inputElement.type) &&
        !inputElement.hasAttribute("data-validator-ignore")) {
        if (["radio", "checkbox"].includes(inputElement.type)) {
          inputElement.checked = false;
        } else {
          inputElement.value = "";
        }
        inputElement.removeAttribute("data-invalid");
        inputElement.removeAttribute("aria-invalid");
      }
    });

    this.element.dispatchEvent(new CustomEvent("formreset.formvalidator", {
      detail: { form: this.element }
    }));
  }

  /**
   * Enable form validation
   * @returns {void}
   */
  enableValidation() {
    this.validationEnabled = true;
  }

  /**
   * Disable form validation
   * @returns {void}
   */
  disableValidation() {
    this.validationEnabled = false;
  }

  /**
   * Check if validation is currently disabled
   * @returns {boolean} - True if validation is disabled, false otherwise
   */
  isValidationCurrentlyDisabled() {
    if (!this.validationEnabled) {
      return true;
    }
    if (typeof this.formnovalidate === "boolean") {
      return this.formnovalidate;
    }
    return this.submitElements.length > 0 && this.submitElements[0].getAttribute("formnovalidate") !== null;
  }

  /**
   * Check if input validation should be skipped
   * @param {HTMLElement} inputElement - The input element
   * @returns {boolean} - True if validation should be skipped, false otherwise
   */
  shouldSkipInputValidation(inputElement) {
    return inputElement.hasAttribute("data-validator-ignore") ||
      inputElement.type === "hidden" ||
      inputElement.disabled;
  }

  /**
   * Generate a unique identifier for elements
   * @param {string} prefix - Prefix for the identifier
   * @returns {string} - Unique identifier
   */
  generateUniqueIdentifier(prefix = "validator") {
    return `${prefix}-${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Destroy the validator instance and clean up
   * @returns {void}
   */
  destroyValidator() {
    // Remove all event listeners by cloning and replacing the form
    // This is a simple way to remove all event listeners
    this.element.removeEventListener("submit", this.validateEntireForm);
    this.element.removeEventListener("reset", this.resetFormValidation);

    // Remove error display
    this.element.querySelectorAll("[data-form-error]").forEach((element) => {
      element.style.display = "none";
    });

    // Clean up input error classes
    this.inputElements.forEach((inputElement) => {
      this.removeInputErrorClasses(inputElement);
    });
  }
}

export default FormValidator;
