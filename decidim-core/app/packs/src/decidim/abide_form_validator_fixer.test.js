/* global jest */

import AbideFormValidatorFixer from "src/decidim/abide_form_validator_fixer";

describe("AbideFormValidatorFixer", () => {
  let originalFoundation = null;

  beforeEach(() => {
    originalFoundation = window.Foundation;

    class MockAbide {}

    MockAbide.prototype.validateCheckbox = function() {
      return false;
    };

    window.Foundation = { Abide: MockAbide };
  });

  afterEach(() => {
    window.Foundation = originalFoundation;
    document.body.innerHTML = "";
  });

  it("removes checkbox group error classes once when the group is valid", () => {
    const fixer = new AbideFormValidatorFixer();
    fixer.patchCheckboxValidation();

    const form = document.createElement("form");
    form.innerHTML = `
      <input type="checkbox" name="largeGroup" value="1" required checked>
      <input type="checkbox" name="largeGroup" value="2" required>
      <input type="checkbox" name="largeGroup" value="3" required>
    `;

    const abideInstance = {
      $element: window.$(form),
      initialized: true,
      addErrorClasses: jest.fn(),
      removeCheckboxErrorClasses: jest.fn()
    };

    const valid = Reflect.apply(window.Foundation.Abide.prototype.validateCheckbox, abideInstance, ["largeGroup"]);

    expect(valid).toBe(true);
    expect(abideInstance.removeCheckboxErrorClasses).toHaveBeenCalledTimes(1);
    expect(abideInstance.addErrorClasses).not.toHaveBeenCalled();
  });

  it("adds error classes per checkbox when the group is invalid", () => {
    const fixer = new AbideFormValidatorFixer();
    fixer.patchCheckboxValidation();

    const form = document.createElement("form");
    form.innerHTML = `
      <input type="checkbox" name="largeGroup" value="1" required>
      <input type="checkbox" name="largeGroup" value="2" required>
      <input type="checkbox" name="largeGroup" value="3" required>
    `;

    const abideInstance = {
      $element: window.$(form),
      initialized: true,
      addErrorClasses: jest.fn(),
      removeCheckboxErrorClasses: jest.fn()
    };

    const valid = Reflect.apply(window.Foundation.Abide.prototype.validateCheckbox, abideInstance, ["largeGroup"]);

    expect(valid).toBe(false);
    expect(abideInstance.addErrorClasses).toHaveBeenCalledTimes(3);
    expect(abideInstance.removeCheckboxErrorClasses).not.toHaveBeenCalled();
  });
});
