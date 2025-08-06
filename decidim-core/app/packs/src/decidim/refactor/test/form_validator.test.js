/* eslint max-lines: ["error", 800] */
/* global jest */
/**
 * @jest-environment jsdom
 */

import FormValidator from "src/decidim/refactor/implementation/form_validator.js";

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
    jest.restoreAllMocks();
  });

  describe("Constructor and Initialization", () => {
    it("should initialize with form element", () => {
      validatorInstance = new FormValidator(formElement);

      expect(validatorInstance.formElement).toBe(formElement);
      expect(validatorInstance.validationEnabled).toBe(true);
      expect(validatorInstance.inputElements).toHaveLength(2);
    });

    it("should initialize with CSS selector", () => {
      formElement.id = "test-form";
      validatorInstance = new FormValidator("#test-form");

      expect(validatorInstance.formElement).toBe(formElement);
    });

    it("should throw error for non-existent form", () => {
      expect(() => {
        // eslint-disable-next-line no-new
        new FormValidator("#non-existent-form");
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
    it("should configure global messages", (done) => {
      const customMessages = {
        correctErrors: "Custom error message"
      };

      FormValidator.configureMessages(customMessages);

      validatorInstance = new FormValidator(formElement);
      validatorInstance.announceFormErrorForScreenReader();

      setTimeout(() => {
        const announceElement = formElement.querySelector(".sr-announce");
        expect(announceElement.textContent).toBe("Custom error message");
        done();
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
      expect(textInput.getAttribute("aria-invalid")).toBe("true");

      // Test with value (should be valid)
      textInput.value = "test value";
      const isValidFilled = validatorInstance.validateSingleInput(textInput);
      expect(isValidFilled).toBe(true);
      expect(textInput.classList.contains("is-invalid-input")).toBe(false);
      expect(textInput.hasAttribute("aria-invalid")).toBe(false);
    });

    it("should validate email input pattern", () => {
      const emailInput = formElement.querySelector("#email-input");

      // Test invalid email
      emailInput.value = "invalid-email";
      const isInvalidEmail = validatorInstance.validateSingleInput(emailInput);
      expect(isInvalidEmail).toBe(false);
      expect(emailInput.classList.contains("is-invalid-input")).toBe(true);

      // Test valid email
      emailInput.value = "test@example.com";
      const isValidEmail = validatorInstance.validateSingleInput(emailInput);
      expect(isValidEmail).toBe(true);
      expect(emailInput.classList.contains("is-invalid-input")).toBe(false);
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

    it("should handle disabled inputs", () => {
      const textInput = formElement.querySelector("#test-input");
      textInput.disabled = true;

      const isValid = validatorInstance.validateSingleInput(textInput);
      expect(isValid).toBe(true);
    });

    it("should handle null inputs", () => {
      const isValid = validatorInstance.validateSingleInput(null);
      expect(isValid).toBe(true);
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

    it("should validate radio button group correctly", () => {
      const radio1 = formElement.querySelector("#option-1");
      const radio2 = formElement.querySelector("#option-2");

      // No selection should be invalid
      const isValidEmpty = validatorInstance.validateRadioGroup("option");
      expect(isValidEmpty).toBe(false);
      expect(radio1.classList.contains("is-invalid-input")).toBe(true);
      expect(radio2.classList.contains("is-invalid-input")).toBe(true);

      // With selection should be valid
      radio1.checked = true;
      const isValidChecked = validatorInstance.validateRadioGroup("option");
      expect(isValidChecked).toBe(true);
      expect(radio1.classList.contains("is-invalid-input")).toBe(false);
      expect(radio2.classList.contains("is-invalid-input")).toBe(false);
    });

    it("should return true for non-existent radio group", () => {
      const isValid = validatorInstance.validateRadioGroup("non-existent");
      expect(isValid).toBe(true);
    });

    it("should return true for non-required radio group", () => {
      formElement.innerHTML = `
        <input type="radio" name="optional" value="1">
        <input type="radio" name="optional" value="2">
      `;

      const isValid = validatorInstance.validateRadioGroup("optional");
      expect(isValid).toBe(true);
    });

    it("should skip radio buttons in validateSingleInput", () => {
      const radio = formElement.querySelector("#option-1");
      const isValid = validatorInstance.validateSingleInput(radio);
      expect(isValid).toBe(true);
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

    it("should validate checkbox group correctly", () => {
      const checkbox1 = formElement.querySelector("#checkbox-1");
      const checkbox2 = formElement.querySelector("#checkbox-2");

      // No selection should be invalid
      const isValidEmpty = validatorInstance.validateCheckboxGroup("checkboxes");
      expect(isValidEmpty).toBe(false);
      expect(checkbox1.classList.contains("is-invalid-input")).toBe(true);
      expect(checkbox2.classList.contains("is-invalid-input")).toBe(true);

      // With selection should be valid
      checkbox1.checked = true;
      const isValidChecked = validatorInstance.validateCheckboxGroup("checkboxes");
      expect(isValidChecked).toBe(true);
      expect(checkbox1.classList.contains("is-invalid-input")).toBe(false);
      expect(checkbox2.classList.contains("is-invalid-input")).toBe(false);
    });

    it("should handle minimum required checkboxes", () => {
      const checkbox1 = formElement.querySelector("#checkbox-1");
      const checkbox2 = formElement.querySelector("#checkbox-2");
      checkbox1.setAttribute("data-min-required", "2");

      // One selection should be invalid
      checkbox1.checked = true;
      const isValidOne = validatorInstance.validateCheckboxGroup("checkboxes");
      expect(isValidOne).toBe(false);

      // Two selections should be valid
      checkbox2.checked = true;
      const isValidTwo = validatorInstance.validateCheckboxGroup("checkboxes");
      expect(isValidTwo).toBe(true);
    });

    it("should validate single checkbox", () => {
      formElement.innerHTML = `
        <input type="checkbox" id="single-checkbox" name="single" required>
        <label for="single-checkbox">Accept terms</label>
      `;
      validatorInstance = new FormValidator(formElement);

      const checkbox = formElement.querySelector("#single-checkbox");

      // Unchecked should be invalid
      const isValidUnchecked = validatorInstance.validateSingleInput(checkbox);
      expect(isValidUnchecked).toBe(false);
      expect(checkbox.classList.contains("is-invalid-input")).toBe(true);

      // Checked should be valid
      checkbox.checked = true;
      const isValidChecked = validatorInstance.validateSingleInput(checkbox);
      expect(isValidChecked).toBe(true);
      expect(checkbox.classList.contains("is-invalid-input")).toBe(false);
    });

    it("should skip checkbox groups in validateSingleInput", () => {
      const checkbox = formElement.querySelector("#checkbox-1");
      const isValid = validatorInstance.validateSingleInput(checkbox);
      expect(isValid).toBe(true);
    });
  });

  describe("Select Validation", () => {
    beforeEach(() => {
      formElement.innerHTML = `
        <div>
          <label for="select-input">Choose Option</label>
          <select id="select-input" name="selectInput" required>
            <option value="">Choose...</option>
            <option value="1">Option 1</option>
            <option value="2">Option 2</option>
          </select>
          <span class="form-error">Please select an option</span>
        </div>
        <button type="submit">Submit</button>
      `;
      validatorInstance = new FormValidator(formElement);
    });

    it("should validate required select element", () => {
      const selectInput = formElement.querySelector("#select-input");

      // Empty selection should be invalid
      const isValidEmpty = validatorInstance.validateSingleInput(selectInput);
      expect(isValidEmpty).toBe(false);
      expect(selectInput.classList.contains("is-invalid-input")).toBe(true);

      // With selection should be valid
      selectInput.value = "1";
      const isValidFilled = validatorInstance.validateSingleInput(selectInput);
      expect(isValidFilled).toBe(true);
      expect(selectInput.classList.contains("is-invalid-input")).toBe(false);
    });
  });

  describe("Textarea Validation", () => {
    beforeEach(() => {
      formElement.innerHTML = `
        <div>
          <label for="textarea-input">Comments</label>
          <textarea id="textarea-input" name="textareaInput" required></textarea>
          <span class="form-error">Please enter your comments</span>
        </div>
        <button type="submit">Submit</button>
      `;
      validatorInstance = new FormValidator(formElement);
    });

    it("should validate required textarea element", () => {
      const textareaInput = formElement.querySelector("#textarea-input");

      // Empty textarea should be invalid
      const isValidEmpty = validatorInstance.validateSingleInput(textareaInput);
      expect(isValidEmpty).toBe(false);
      expect(textareaInput.classList.contains("is-invalid-input")).toBe(true);

      // With content should be valid
      textareaInput.value = "Some content";
      const isValidFilled = validatorInstance.validateSingleInput(textareaInput);
      expect(isValidFilled).toBe(true);
      expect(textareaInput.classList.contains("is-invalid-input")).toBe(false);
    });

    it("should trim whitespace in textarea validation", () => {
      const textareaInput = formElement.querySelector("#textarea-input");

      // Whitespace only should be invalid
      textareaInput.value = "   \n\t  ";
      const isValid = validatorInstance.validateSingleInput(textareaInput);
      expect(isValid).toBe(false);
    });
  });

  describe("Mixed Form Types", () => {
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

  describe("Error Handling and Screen Reader Support", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should handle error events", () => {
      const spy = jest.spyOn(validatorInstance, "announceFormError");
      validatorInstance.handleError();
      expect(spy).toHaveBeenCalled();
    });

    it("should focus first invalid input on error", () => {
      const textInput = formElement.querySelector("#test-input");
      textInput.classList.add("is-invalid-input");

      const focusSpy = jest.spyOn(textInput, "focus");
      validatorInstance.handleError();
      expect(focusSpy).toHaveBeenCalled();
    });

    it("should announce errors for screen readers", (done) => {
      validatorInstance.announceFormErrorForScreenReader();

      setTimeout(() => {
        const announceElement = formElement.querySelector(".sr-announce");
        expect(announceElement).toBeTruthy();
        expect(announceElement.classList.contains("sr-only")).toBe(true);
        expect(announceElement.getAttribute("aria-live")).toBe("assertive");
        done();
      }, 150);
    });

    it("should remove existing announce element before creating new one", (done) => {
      // Create initial announce element
      validatorInstance.announceFormErrorForScreenReader();

      setTimeout(() => {
        // Create another one
        validatorInstance.announceFormErrorForScreenReader();

        setTimeout(() => {
          const announceElements = formElement.querySelectorAll(".sr-announce");
          expect(announceElements.length).toBe(1);
          done();
        }, 50);
      }, 150);
    });
  });

  describe("Error Classes Management", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should add error classes correctly", () => {
      const input = formElement.querySelector("#test-input");

      validatorInstance.addErrorClasses(input);

      expect(input.classList.contains("is-invalid-input")).toBe(true);
      expect(input.getAttribute("aria-invalid")).toBe("true");
    });

    it("should remove error classes correctly", () => {
      const input = formElement.querySelector("#test-input");
      input.classList.add("is-invalid-input");
      input.setAttribute("aria-invalid", "true");

      validatorInstance.removeErrorClasses(input);

      expect(input.classList.contains("is-invalid-input")).toBe(false);
      expect(input.hasAttribute("aria-invalid")).toBe(false);
    });

    it("should use custom error class", () => {
      validatorInstance = new FormValidator(formElement, { inputErrorClass: "custom-error" });
      const input = formElement.querySelector("#test-input");

      validatorInstance.addErrorClasses(input);

      expect(input.classList.contains("custom-error")).toBe(true);
      expect(input.classList.contains("is-invalid-input")).toBe(false);
    });
  });

  describe("Cleanup and Destruction", () => {
    it("should clean up validation on destroy", () => {
      const input = formElement.querySelector("#test-input");
      input.classList.add("is-invalid-input");

      validatorInstance = new FormValidator(formElement);
      validatorInstance.destroyValidator();

      expect(input.classList.contains("is-invalid-input")).toBe(false);
    });
  });

  describe("Edge Cases", () => {
    beforeEach(() => {
      validatorInstance = new FormValidator(formElement);
    });

    it("should handle empty email validation", () => {
      const emailInput = formElement.querySelector("#email-input");
      emailInput.required = false;
      emailInput.value = "";

      const isValid = validatorInstance.validateSingleInput(emailInput);
      expect(isValid).toBe(true);
    });

    it("should validate email pattern only when there is a value", () => {
      const emailInput = formElement.querySelector("#email-input");
      emailInput.required = false;
      emailInput.value = "invalid-email";

      const isValid = validatorInstance.validateSingleInput(emailInput);
      expect(isValid).toBe(false);
    });

    it("should handle forms without radio groups", () => {
      const result = validatorInstance.validateEntireForm();
      // Should not crash and should return validation result
      expect(typeof result).toBe("boolean");
    });

    it("should handle forms without checkbox groups", () => {
      const result = validatorInstance.validateEntireForm();
      // Should not crash and should return validation result
      expect(typeof result).toBe("boolean");
    });

    it("should handle whitespace-only input validation", () => {
      const textInput = formElement.querySelector("#test-input");
      textInput.value = "   \n\t  ";

      const isValid = validatorInstance.validateSingleInput(textInput);
      expect(isValid).toBe(false);
    });
  });
});
