/* eslint max-lines: ["error", 690] */
/* global jest */
/**
 * @jest-environment jsdom
 */

import FormValidator from "src/decidim/controllers/form_validator/form_validator"

describe("FormValidator", () => {
  let formElement = null;
  let validatorInstance = null;

  beforeEach(() => {
    // Reset DOM
    document.body.innerHTML = "";

    // Create basic form structure
    formElement = document.createElement("form");
    formElement.innerHTML = `
      <div>
        <label for="test-input">Test Input</label>
        <input type="text" id="test-input" name="testInput" required>
        <span class="form-error">This field is required</span>
      </div>
      <div>
        <label for="email-input">Email</label>
        <input type="email" id="email-input" name="emailInput" required>
        <span class="form-error">Please enter a valid email</span>
      </div>
      <button type="submit">Submit</button>
    `;
    document.body.appendChild(formElement);
  });

  afterEach(() => {
    if (validatorInstance) {
      validatorInstance.destroyValidator();
    }
    jest.clearAllMocks();
  });

  describe("Constructor and Initialization", () => {
    it("should initialize with form element", () => {
      validatorInstance = new FormValidator(formElement);

      expect(validatorInstance.element).toBe(formElement);
      expect(validatorInstance.validationEnabled).toBe(true);
      expect(validatorInstance.inputElements).toHaveLength(2);
    });

    it("should initialize with CSS selector", () => {
      formElement.id = "test-form";
      validatorInstance = new FormValidator("#test-form");

      expect(validatorInstance.element).toBe(formElement);
    });

    it("should throw error for nonexistent form", () => {
      expect(() => {
        // eslint-disable-next-line no-new
        new FormValidator("#nonexistent-form");
      }).toThrow("Form element not found");
    });

    it("should initialize with custom validation options", () => {
      const customOptions = {
        validateOn: "submit",
        inputErrorClass: "custom-error"
      };

      validatorInstance = new FormValidator(formElement, customOptions);

      expect(validatorInstance.validationOptions.validateOn).toBe("submit");
      expect(validatorInstance.validationOptions.inputErrorClass).toBe("custom-error");
    });
  });

  describe("Static Methods", () => {
    it("should configure global messages", () => {
      Reflect.defineProperty(window, "Decidim", {
        writable: true,
        value: {
          config: {
            data: {},
            set: jest.fn(function(config) {
              // eslint-disable-next-line no-invalid-this
              this.data = { ...this.data, ...config };
            }),
            get: jest.fn(function(key) {
              return key
                // eslint-disable-next-line no-invalid-this
                ? this.data[key]
                // eslint-disable-next-line no-invalid-this
                : this.data;
            })
          }
        }
      });

      window.Decidim.config.set({
        messages: {
          forms: {
            "correct_errors": "Custom error message"
          }
        }
      })

      validatorInstance = new FormValidator(formElement);
      validatorInstance.announceFormErrorForScreenReader();

      setTimeout(() => {
        const announceElement = formElement.querySelector(".sr-announce");
        expect(announceElement.textContent).toBe("Custom error message");
      }, 150);
    });
  });

  describe("Form Validation", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should validate required text input", () => {
      const textInput = formElement.querySelector("#test-input");

      // Test empty value (should be invalid)
      textInput.value = "";
      const isValidEmpty = validatorInstance.validateSingleInput(textInput);
      expect(isValidEmpty).toBe(false);
      expect(textInput.classList.contains("is-invalid-input")).toBe(true);

      // Test with value (should be valid)
      textInput.value = "test value";
      const isValidFilled = validatorInstance.validateSingleInput(textInput);
      expect(isValidFilled).toBe(true);
      expect(textInput.classList.contains("is-invalid-input")).toBe(false);
    });

    it("should validate email input pattern", () => {
      const emailInput = formElement.querySelector("#email-input");

      // Test invalid email
      emailInput.value = "invalid-email";
      const isInvalidEmail = validatorInstance.validateSingleInput(emailInput);
      expect(isInvalidEmail).toBe(false);

      // Test valid email
      emailInput.value = "test@example.com";
      const isValidEmail = validatorInstance.validateSingleInput(emailInput);
      expect(isValidEmail).toBe(true);
    });

    it("should validate entire form", () => {
      const textInput = formElement.querySelector("#test-input");
      const emailInput = formElement.querySelector("#email-input");

      // Empty form should be invalid
      const isFormValidEmpty = validatorInstance.validateEntireForm();
      expect(isFormValidEmpty).toBe(false);

      // Fill with valid data
      textInput.value = "test value";
      emailInput.value = "test@example.com";

      const isFormValidFilled = validatorInstance.validateEntireForm();
      expect(isFormValidFilled).toBe(true);
    });
  });

  describe("Radio Button Validation", () => {
    beforeEach(() => {
      formElement.innerHTML = `
        <fieldset>
          <legend>Choose Option</legend>
          <input type="radio" id="option-1" name="option" value="1" required>
          <label for="option-1">Option 1</label>
          <input type="radio" id="option-2" name="option" value="2" required>
          <label for="option-2">Option 2</label>
          <span class="form-error">Please select an option</span>
        </fieldset>
        <button type="submit">Submit</button>
      `;
      validatorInstance = new FormValidator(formElement);
    });

    it("should validate radio button group", () => {
      const radio1 = formElement.querySelector("#option-1");

      // No selection should be invalid
      const isValidEmpty = validatorInstance.validateRadioGroup("option");
      expect(isValidEmpty).toBe(false);

      // With selection should be valid
      radio1.checked = true;
      const isValidChecked = validatorInstance.validateRadioGroup("option");
      expect(isValidChecked).toBe(true);
    });
  });

  describe("Checkbox Validation", () => {
    beforeEach(() => {
      formElement.innerHTML = `
        <fieldset>
          <legend>Select Options</legend>
          <input type="checkbox" id="checkbox-1" name="checkboxes" value="1" required>
          <label for="checkbox-1">Checkbox 1</label>
          <input type="checkbox" id="checkbox-2" name="checkboxes" value="2" required>
          <label for="checkbox-2">Checkbox 2</label>
          <span class="form-error">Please select at least one option</span>
        </fieldset>
        <button type="submit">Submit</button>
      `;
      validatorInstance = new FormValidator(formElement);
    });

    it("should validate checkbox group", () => {
      const checkbox1 = formElement.querySelector("#checkbox-1");

      // No selection should be invalid
      const isValidEmpty = validatorInstance.validateCheckboxGroup("checkboxes");
      expect(isValidEmpty).toBe(false);

      // With selection should be valid
      checkbox1.checked = true;
      const isValidChecked = validatorInstance.validateCheckboxGroup("checkboxes");
      expect(isValidChecked).toBe(true);
    });

    it("should validate minimum required checkboxes", () => {
      formElement.innerHTML = `
        <fieldset>
          <input type="checkbox" id="multi-1" name="multiCheckboxes" value="1" required data-min-required="2">
          <label for="multi-1">Multi 1</label>
          <input type="checkbox" id="multi-2" name="multiCheckboxes" value="2" required data-min-required="2">
          <label for="multi-2">Multi 2</label>
          <input type="checkbox" id="multi-3" name="multiCheckboxes" value="3" required data-min-required="2">
          <label for="multi-3">Multi 3</label>
        </fieldset>
      `;
      validatorInstance = new FormValidator(formElement);

      const checkbox1 = formElement.querySelector("#multi-1");
      const checkbox2 = formElement.querySelector("#multi-2");

      validatorInstance.validateEntireForm();
      // One checkbox should be invalid (minimum 2 required)
      checkbox1.checked = true;
      const isValidOne = validatorInstance.validateCheckboxGroup("multiCheckboxes");
      expect(isValidOne).toBe(false);

      // Two checkboxes should be valid
      checkbox2.checked = true;
      const isValidTwo = validatorInstance.validateCheckboxGroup("multiCheckboxes");
      expect(isValidTwo).toBe(true);
    });
  });

  describe("Custom Validators", () => {
    beforeEach(() => {
      formElement.innerHTML = `
        <div>
          <label for="password">Password</label>
          <input type="password" id="password" name="password" required>
        </div>
        <div>
          <label for="confirm-password">Confirm Password</label>
          <input type="password" id="confirm-password" name="confirmPassword" required data-equalto="password">
          <span class="form-error">Passwords must match</span>
        </div>
        <button type="submit">Submit</button>
      `;
      validatorInstance = new FormValidator(formElement);
    });

    it("should validate equalTo validator", () => {
      const passwordInput = formElement.querySelector("#password");
      const confirmPasswordInput = formElement.querySelector("#confirm-password");

      passwordInput.value = "password123";
      confirmPasswordInput.value = "different";

      // Passwords do not match
      const isValidDifferent = validatorInstance.validateSingleInput(confirmPasswordInput);
      expect(isValidDifferent).toBe(false);

      // Passwords match
      confirmPasswordInput.value = "password123";
      const isValidMatching = validatorInstance.validateSingleInput(confirmPasswordInput);
      expect(isValidMatching).toBe(true);
    });
  });

  describe("Pattern Validation", () => {
    beforeEach(() => {
      formElement.innerHTML = `
        <div>
          <label for="alpha-input">Alpha Only</label>
          <input type="text" id="alpha-input" name="alphaInput" data-pattern="alpha" required>
          <span class="form-error">Only letters allowed</span>
        </div>
        <div>
          <label for="number-input">Number Only</label>
          <input type="text" id="number-input" name="numberInput" data-pattern="integer" required>
          <span class="form-error">Only numbers allowed</span>
        </div>
        <button type="submit">Submit</button>
      `;
      validatorInstance = new FormValidator(formElement);
    });

    it("should validate alpha pattern", () => {
      const alphaInput = formElement.querySelector("#alpha-input");

      // Invalid: contains numbers
      alphaInput.value = "abc123";
      const isValidNumbers = validatorInstance.validateTextInput(alphaInput);
      expect(isValidNumbers).toBe(false);

      // Valid: only letters
      alphaInput.value = "abcDEF";
      const isValidLetters = validatorInstance.validateTextInput(alphaInput);
      expect(isValidLetters).toBe(true);
    });

    it("should validate integer pattern", () => {
      const numberInput = formElement.querySelector("#number-input");

      // Invalid: contains letters
      numberInput.value = "123abc";
      const isValidLetters = validatorInstance.validateTextInput(numberInput);
      expect(isValidLetters).toBe(false);

      // Valid: only numbers
      numberInput.value = "12345";
      const isValidNumbers = validatorInstance.validateTextInput(numberInput);
      expect(isValidNumbers).toBe(true);
    });
  });

  describe("Error Class Management", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should add error classes to invalid inputs", () => {
      const textInput = formElement.querySelector("#test-input");
      const labelElement = formElement.querySelector('label[for="test-input"]');

      textInput.value = "";
      validatorInstance.validateSingleInput(textInput);

      expect(textInput.classList.contains("is-invalid-input")).toBe(true);
      expect(textInput.getAttribute("aria-invalid")).toBe("true");
      expect(labelElement.classList.contains("is-invalid-label")).toBe(true);
    });

    it("should remove error classes from valid inputs", () => {
      const textInput = formElement.querySelector("#test-input");
      const labelElement = formElement.querySelector('label[for="test-input"]');

      // First make it invalid
      textInput.value = "";
      validatorInstance.validateSingleInput(textInput);

      // Then make it valid
      textInput.value = "valid text";
      validatorInstance.validateSingleInput(textInput);

      expect(textInput.classList.contains("is-invalid-input")).toBe(false);
      expect(textInput.hasAttribute("aria-invalid")).toBe(false);
      expect(labelElement.classList.contains("is-invalid-label")).toBe(false);
    });
  });

  describe("Accessibility Features", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should add accessibility attributes to inputs", () => {
      const textInput = formElement.querySelector("#test-input");
      const errorElement = formElement.querySelector(".form-error");

      validatorInstance.addAccessibilityAttributes(textInput);

      expect(errorElement.getAttribute("role")).toBe("alert");
    });

    it("should announce form errors for screen readers", () => {
      validatorInstance.announceFormErrorForScreenReader();

      const announceElement = formElement.querySelector(".sr-announce");
      expect(announceElement).toBeTruthy();
      expect(announceElement.getAttribute("aria-live")).toBe("assertive");
      expect(announceElement.classList.contains("sr-only")).toBe(true);
    });

    it("should link inputs to error messages with aria-describedby", () => {
      const textInput = formElement.querySelector("#test-input");
      const errorElement = formElement.querySelector(".form-error");

      validatorInstance.addAccessibilityErrorDescribe(textInput, errorElement);

      expect(errorElement.id).toBeTruthy();
      expect(textInput.getAttribute("aria-describedby")).toBe(errorElement.id);
    });
  });

  describe("Form Submission Handling", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should prevent submission of invalid form", () => {
      const submitEvent = new Event("submit", { cancelable: true });
      const preventDefault = jest.spyOn(submitEvent, "preventDefault");

      // Empty form should be invalid
      formElement.dispatchEvent(submitEvent);

      expect(preventDefault).toHaveBeenCalled();
    });

    it("should allow submission of valid form", () => {
      const textInput = formElement.querySelector("#test-input");
      const emailInput = formElement.querySelector("#email-input");
      const submitEvent = new Event("submit", { cancelable: true });
      const preventDefault = jest.spyOn(submitEvent, "preventDefault");

      // Fill form with valid data
      textInput.value = "test value";
      emailInput.value = "test@example.com";

      formElement.dispatchEvent(submitEvent);

      expect(preventDefault).not.toHaveBeenCalled();
    });

    it("should respect formnovalidate attribute", () => {
      const submitButton = formElement.querySelector('button[type="submit"]');
      submitButton.setAttribute("formnovalidate", "");

      const submitEvent = new Event("submit", { cancelable: true });
      const preventDefault = jest.spyOn(submitEvent, "preventDefault");

      // Click submit button to set formnovalidate flag
      submitButton.click();

      // Empty form should still be allowed with formnovalidate
      formElement.dispatchEvent(submitEvent);

      expect(preventDefault).not.toHaveBeenCalled();
    });
  });

  describe("Event Handling", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should trigger validation events", () => {
      const textInput = formElement.querySelector("#test-input");
      let validEventFired = false;
      let invalidEventFired = false;

      textInput.addEventListener("valid.formvalidator", () => {
        validEventFired = true;
      });

      textInput.addEventListener("invalid.formvalidator", () => {
        invalidEventFired = true;
      });

      // Test invalid input
      textInput.value = "";
      validatorInstance.validateSingleInput(textInput);
      expect(invalidEventFired).toBe(true);

      // Test valid input
      textInput.value = "valid text";
      validatorInstance.validateSingleInput(textInput);
      expect(validEventFired).toBe(true);
    });

    it("should trigger form validation events", () => {
      let formValidEventFired = false;
      let formInvalidEventFired = false;

      formElement.addEventListener("formvalid.formvalidator", () => {
        formValidEventFired = true;
      });

      formElement.addEventListener("forminvalid.formvalidator", () => {
        formInvalidEventFired = true;
      });

      // Test invalid form
      validatorInstance.validateEntireForm();
      expect(formInvalidEventFired).toBe(true);

      // Test valid form
      const textInput = formElement.querySelector("#test-input");
      const emailInput = formElement.querySelector("#email-input");
      textInput.value = "test value";
      emailInput.value = "test@example.com";

      validatorInstance.validateEntireForm();
      expect(formValidEventFired).toBe(true);
    });
  });

  describe("Form Reset Functionality", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should reset form validation state", () => {
      const textInput = formElement.querySelector("#test-input");

      // Make input invalid first
      textInput.value = "";
      validatorInstance.validateSingleInput(textInput);
      expect(textInput.classList.contains("is-invalid-input")).toBe(true);

      // Reset validation
      validatorInstance.resetFormValidation();

      expect(textInput.classList.contains("is-invalid-input")).toBe(false);
      expect(textInput.value).toBe("");
      expect(textInput.hasAttribute("aria-invalid")).toBe(false);
    });

    it("should trigger reset event", () => {
      let resetEventFired = false;

      formElement.addEventListener("formreset.formvalidator", () => {
        resetEventFired = true;
      });

      validatorInstance.resetFormValidation();
      expect(resetEventFired).toBe(true);
    });
  });

  describe("Validation Control", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should enable and disable validation", () => {
      validatorInstance.disableValidation();
      expect(validatorInstance.isValidationCurrentlyDisabled()).toBe(true);

      validatorInstance.enableValidation();
      expect(validatorInstance.isValidationCurrentlyDisabled()).toBe(false);
    });

    it("should skip validation for disabled inputs", () => {
      const textInput = formElement.querySelector("#test-input");
      textInput.disabled = true;

      const shouldSkip = validatorInstance.shouldSkipInputValidation(textInput);
      expect(shouldSkip).toBe(true);
    });

    it("should skip validation for inputs with ignore attribute", () => {
      const textInput = formElement.querySelector("#test-input");
      textInput.setAttribute("data-validator-ignore", "");

      const shouldSkip = validatorInstance.shouldSkipInputValidation(textInput);
      expect(shouldSkip).toBe(true);
    });
  });

  describe("Legacy Compatibility", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should handle legacy form-error.decidim event", () => {
      const mockAnnounce = jest.spyOn(validatorInstance, "announceFormErrorForScreenReader");

      formElement.dispatchEvent(new CustomEvent("form-error.decidim"));

      expect(mockAnnounce).toHaveBeenCalled();
    });

    it("should trigger legacy event on form validation failure", () => {
      let legacyEventFired = false;

      formElement.addEventListener("form-error.decidim", () => {
        legacyEventFired = true;
      });

      // Trigger form invalid event which should trigger legacy event
      formElement.dispatchEvent(new CustomEvent("forminvalid.formvalidator"));

      expect(legacyEventFired).toBe(true);
    });
  });

  describe("Utility Methods", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should generate unique identifiers", () => {
      const identifier1 = validatorInstance.generateUniqueIdentifier("test");
      const identifier2 = validatorInstance.generateUniqueIdentifier("test");

      expect(identifier1).toMatch(/^test-/);
      expect(identifier2).toMatch(/^test-/);
      expect(identifier1).not.toBe(identifier2);
    });

    it("should find input labels correctly", () => {
      const textInput = formElement.querySelector("#test-input");
      const labelElement = validatorInstance.findInputLabel(textInput);

      expect(labelElement.getAttribute("for")).toBe("test-input");
    });

    it("should find form error elements", () => {
      const textInput = formElement.querySelector("#test-input");
      const errorElements = validatorInstance.findFormErrorElements(textInput);

      expect(errorElements.length).toBeGreaterThan(0);
      expect(errorElements[0].classList.contains("form-error")).toBe(true);
    });
  });

  describe("Destroy Validator", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should clean up validator instance", () => {
      const textInput = formElement.querySelector("#test-input");

      // Make input invalid
      textInput.value = "";
      validatorInstance.validateSingleInput(textInput);
      expect(textInput.classList.contains("is-invalid-input")).toBe(true);

      // Destroy validator
      validatorInstance.destroyValidator();

      expect(textInput.classList.contains("is-invalid-input")).toBe(false);
    });
  });

  describe("Complex Form Scenarios", () => {
    it("should handle forms with mixed input types", () => {
      formElement.innerHTML = `
        <input type="text" name="text" required>
        <input type="email" name="email" required>
        <input type="radio" name="radio" value="1" required>
        <input type="radio" name="radio" value="2" required>
        <input type="checkbox" name="checkbox" required>
        <select name="select" required>
          <option value="">Choose...</option>
          <option value="1">Option 1</option>
        </select>
        <textarea name="textarea" required></textarea>
        <button type="submit">Submit</button>
      `;

      validatorInstance = new FormValidator(formElement);

      // Initially invalid
      expect(validatorInstance.validateEntireForm()).toBe(false);

      // Fill all fields
      formElement.querySelector('input[name="text"]').value = "text";
      formElement.querySelector('input[name="email"]').value = "test@example.com";
      formElement.querySelector('input[name="radio"][value="1"]').checked = true;
      formElement.querySelector('input[name="checkbox"]').checked = true;
      formElement.querySelector('select[name="select"]').value = "1";
      formElement.querySelector('textarea[name="textarea"]').value = "textarea content";

      // Should now be valid
      expect(validatorInstance.validateEntireForm()).toBe(true);
    });
  });
});
