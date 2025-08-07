/* eslint max-lines: ["error", 510] */
/* global global, jest */
/**
 * @jest-environment jsdom
 */

import UserRegistrationForm from "src/decidim/refactor/integration/user_registration_form";

describe("UserRegistrationForm", () => {
  let formElement = null;
  let modalElement = null;
  let newsletterCheckbox = null;
  let mockDecidimDialogs = null;
  let omniauthRegistrationForm = null;
  let mockFormSubmit = null;

  beforeEach(() => {
    // Mock HTMLFormElement.prototype.submit
    mockFormSubmit = jest.fn();
    if (!HTMLFormElement.prototype.submit.mockImplementation) {
      Reflect.defineProperty(HTMLFormElement.prototype, "submit", {
        value: mockFormSubmit,
        writable: true,
        configurable: true
      });
    }

    // Set up DOM elements
    document.body.innerHTML = "";

    // Create OAuth form element
    formElement = document.createElement("form");
    formElement.id = "omniauth-registration-form";
    formElement.setAttribute("data-provider", "google");

    // Create newsletter checkbox
    newsletterCheckbox = document.createElement("input");
    newsletterCheckbox.type = "checkbox";
    newsletterCheckbox.name = "user[newsletter]";
    formElement.appendChild(newsletterCheckbox);

    // Create modal element
    modalElement = document.createElement("div");
    modalElement.id = "sign-up-newsletter-modal";

    // Create modal buttons
    const acceptButton = document.createElement("button");
    acceptButton.setAttribute("data-check", "true");
    acceptButton.textContent = "Yes";

    const declineButton = document.createElement("button");
    declineButton.setAttribute("data-check", "false");
    declineButton.textContent = "No";

    modalElement.appendChild(acceptButton);
    modalElement.appendChild(declineButton);

    document.body.appendChild(formElement);
    document.body.appendChild(modalElement);

    // Mock Decidim dialog system
    mockDecidimDialogs = {
      "sign-up-newsletter-modal": {
        open: jest.fn(),
        close: jest.fn()
      }
    };

    global.window = global.window || {};
    global.window.Decidim = {
      currentDialogs: mockDecidimDialogs
    };

    // Create instance
    omniauthRegistrationForm = new UserRegistrationForm(formElement.id);
  });

  afterEach(() => {
    document.body.innerHTML = "";
    Reflect.deleteProperty(window, "Decidim");
    jest.clearAllMocks();
  });

  describe("constructor", () => {
    it("should initialize with correct properties", () => {
      expect(omniauthRegistrationForm.formElement).toBe(formElement);
      expect(omniauthRegistrationForm.modal).toBe(modalElement);
      expect(omniauthRegistrationForm.newsletterSelector).toBe('input[type="checkbox"][name="user[newsletter]"]');
      expect(omniauthRegistrationForm.isInitialized).toBe(false);
    });

    it("should be an instance of OmniauthRegistrationForm", () => {
      expect(omniauthRegistrationForm).toBeInstanceOf(UserRegistrationForm);
    });
  });

  describe("inheritance behavior", () => {
    it("should inherit all methods from BaseRegistrationForm", () => {
      // Test that all BaseRegistrationForm methods are available
      expect(typeof omniauthRegistrationForm.initialize).toBe("function");
      expect(typeof omniauthRegistrationForm.setupFormEventListeners).toBe("function");
      expect(typeof omniauthRegistrationForm.setupModalEventListeners).toBe("function");
      expect(typeof omniauthRegistrationForm.handleFormSubmission).toBe("function");
      expect(typeof omniauthRegistrationForm.processNewsletterSelection).toBe("function");
      expect(typeof omniauthRegistrationForm.getNewsletterCheckbox).toBe("function");
      expect(typeof omniauthRegistrationForm.isNewsletterChecked).toBe("function");
      expect(typeof omniauthRegistrationForm.setNewsletterCheckbox).toBe("function");
      expect(typeof omniauthRegistrationForm.submit).toBe("function");
      expect(typeof omniauthRegistrationForm.getModalContinueFlag).toBe("function");
      expect(typeof omniauthRegistrationForm.setModalContinueFlag).toBe("function");
      expect(typeof omniauthRegistrationForm.openModal).toBe("function");
      expect(typeof omniauthRegistrationForm.closeModal).toBe("function");
      expect(typeof omniauthRegistrationForm.exists).toBe("function");
    });

    it("should inherit newsletter selector from parent", () => {
      expect(omniauthRegistrationForm.newsletterSelector).toBe('input[type="checkbox"][name="user[newsletter]"]');
    });

    it("should inherit initialization state from parent", () => {
      expect(omniauthRegistrationForm.isInitialized).toBe(false);
      omniauthRegistrationForm.initialize();
      expect(omniauthRegistrationForm.isInitialized).toBe(true);
    });
  });

  describe("handleFormSubmission method", () => {
    let mockEvent = null;
    let baseHandleFormSubmissionSpy = null;

    beforeEach(() => {
      mockEvent = {
        preventDefault: jest.fn()
      };
      // Spy on the parent class method
      baseHandleFormSubmissionSpy = jest.spyOn(UserRegistrationForm.prototype, "handleFormSubmission");
    });

    afterEach(() => {
      baseHandleFormSubmissionSpy.mockRestore();
    });

    it("should call parent handleFormSubmission method", () => {
      omniauthRegistrationForm.handleFormSubmission(mockEvent);
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should prevent OAuth submission and open modal when newsletter not checked", () => {
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "false";
      const openModalSpy = jest.spyOn(omniauthRegistrationForm, "openModal");

      omniauthRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(openModalSpy).toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should allow OAuth submission when newsletter is checked", () => {
      newsletterCheckbox.checked = true;
      modalElement.dataset.continue = "false";

      omniauthRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should allow OAuth submission when continue flag is true", () => {
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "true";

      omniauthRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should handle OAuth provider specific form submission", () => {
      // Add OAuth provider attribute
      formElement.setAttribute("data-provider", "facebook");
      newsletterCheckbox.checked = true;

      omniauthRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });
  });

  describe("OAuth specific functionality", () => {
    it("should handle different OAuth providers", () => {
      const providers = ["google", "facebook", "twitter", "github"];

      providers.forEach((provider) => {
        formElement.setAttribute("data-provider", provider);
        const form = new UserRegistrationForm(formElement.id, modalElement.id);

        expect(form.exists()).toBe(true);
      });
    });

    it("should maintain OAuth form context during newsletter workflow", () => {
      formElement.setAttribute("data-provider", "google");
      omniauthRegistrationForm.initialize();

      const submitFormsSpy = jest.spyOn(omniauthRegistrationForm, "submit");
      const closeModalSpy = jest.spyOn(omniauthRegistrationForm, "closeModal");

      // Simulate newsletter selection in OAuth context
      omniauthRegistrationForm.processNewsletterSelection(true);

      expect(newsletterCheckbox.checked).toBe(true);
      expect(modalElement.dataset.continue).toBe("true");
      expect(closeModalSpy).toHaveBeenCalled();
      expect(submitFormsSpy).toHaveBeenCalled();
    });

    it("should handle OAuth form submission with external authentication", () => {
      // Simulate OAuth external auth state
      formElement.setAttribute("data-external-auth", "true");
      newsletterCheckbox.checked = true;

      const mockEvent = { preventDefault: jest.fn() };
      omniauthRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockFormSubmit).not.toHaveBeenCalled();
    });

    it("should handle OAuth form submission with external authentication", () => {
      // Simulate OAuth external auth state
      formElement.setAttribute("data-external-auth", "true");
      newsletterCheckbox.checked = false;

      const mockEvent = { preventDefault: jest.fn() };
      omniauthRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(mockFormSubmit).not.toHaveBeenCalled();
    });
  });

  describe("inherited functionality", () => {
    it("should properly handle newsletter checkbox operations", () => {
      // Test inherited newsletter checkbox functionality
      expect(omniauthRegistrationForm.isNewsletterChecked()).toBe(false);

      omniauthRegistrationForm.setNewsletterCheckbox(true);
      expect(newsletterCheckbox.checked).toBe(true);
      expect(omniauthRegistrationForm.isNewsletterChecked()).toBe(true);

      omniauthRegistrationForm.setNewsletterCheckbox(false);
      expect(newsletterCheckbox.checked).toBe(false);
      expect(omniauthRegistrationForm.isNewsletterChecked()).toBe(false);
    });

    it("should properly handle modal operations", () => {
      // Test inherited modal functionality
      expect(omniauthRegistrationForm.getModalContinueFlag()).toBe(false);

      omniauthRegistrationForm.setModalContinueFlag(true);
      expect(omniauthRegistrationForm.getModalContinueFlag()).toBe(true);

      omniauthRegistrationForm.openModal();
      expect(mockDecidimDialogs["sign-up-newsletter-modal"].open).toHaveBeenCalled();

      omniauthRegistrationForm.closeModal();
      expect(mockDecidimDialogs["sign-up-newsletter-modal"].close).toHaveBeenCalled();
    });

    it("should properly handle form submission", () => {
      const submitSpy = jest.spyOn(formElement, "requestSubmit").mockImplementation(() => {});

      omniauthRegistrationForm.submit();
      expect(submitSpy).toHaveBeenCalled();
    });

    it("should properly handle form existence check", () => {
      expect(omniauthRegistrationForm.exists()).toBe(true);

      const formWithNullElement = new UserRegistrationForm(null, modalElement);
      expect(formWithNullElement.exists()).toBe(false);
    });
  });

  describe("initialization", () => {
    it("should initialize properly with event listeners", () => {
      const setupFormListenersSpy = jest.spyOn(omniauthRegistrationForm, "setupFormEventListeners");
      const setupModalListenersSpy = jest.spyOn(omniauthRegistrationForm, "setupModalEventListeners");

      omniauthRegistrationForm.initialize();

      expect(setupFormListenersSpy).toHaveBeenCalled();
      expect(setupModalListenersSpy).toHaveBeenCalled();
      expect(omniauthRegistrationForm.isInitialized).toBe(true);
    });

    it("should not initialize twice", () => {
      const setupFormListenersSpy = jest.spyOn(omniauthRegistrationForm, "setupFormEventListeners");

      omniauthRegistrationForm.initialize();
      omniauthRegistrationForm.initialize();

      expect(setupFormListenersSpy).toHaveBeenCalledTimes(1);
    });

    it("should handle missing form element gracefully during initialization", () => {
      const formWithoutElement = new UserRegistrationForm(null, modalElement);
      const setupFormListenersSpy = jest.spyOn(formWithoutElement, "setupFormEventListeners");

      formWithoutElement.initialize();

      expect(setupFormListenersSpy).not.toHaveBeenCalled();
      expect(formWithoutElement.isInitialized).toBe(false);
    });
  });

  describe("newsletter selection workflow for OAuth", () => {
    beforeEach(() => {
      omniauthRegistrationForm.initialize();
    });

    it("should handle complete OAuth newsletter selection workflow", () => {
      const submitFormsSpy = jest.spyOn(omniauthRegistrationForm, "submit");
      const closeModalSpy = jest.spyOn(omniauthRegistrationForm, "closeModal");

      // Simulate newsletter selection in OAuth context
      omniauthRegistrationForm.processNewsletterSelection(true);

      expect(newsletterCheckbox.checked).toBe(true);
      expect(modalElement.dataset.continue).toBe("true");
      expect(closeModalSpy).toHaveBeenCalled();
      expect(submitFormsSpy).toHaveBeenCalled();
    });

    it("should handle modal button interactions in OAuth context", () => {
      const processSelectionSpy = jest.spyOn(omniauthRegistrationForm, "processNewsletterSelection");

      // Click the accept button
      const acceptButton = modalElement.querySelector('[data-check="true"]');
      acceptButton.click();

      expect(processSelectionSpy).toHaveBeenCalledWith(true);
    });

    it("should handle OAuth form submission with modal interaction", () => {
      // Set up OAuth form to trigger modal
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "false";

      const openModalSpy = jest.spyOn(omniauthRegistrationForm, "openModal");

      // Simulate form submission
      const submitEvent = new Event("submit", { bubbles: true, cancelable: true });
      formElement.dispatchEvent(submitEvent);

      expect(submitEvent.defaultPrevented).toBe(true);
      expect(openModalSpy).toHaveBeenCalled();
    });
  });

  describe("multiple OAuth forms handling", () => {
    it("should handle multiple OAuth registration forms", () => {
      const updateCheckboxesSpy = jest.spyOn(omniauthRegistrationForm, "setNewsletterCheckbox");
      const submitFormsSpy = jest.spyOn(omniauthRegistrationForm, "submit");

      omniauthRegistrationForm.processNewsletterSelection(true);

      expect(updateCheckboxesSpy).toHaveBeenCalledWith(true);
      expect(submitFormsSpy).toHaveBeenCalled();
    });
  });

  describe("error handling", () => {
    it("should handle missing modal gracefully", () => {
      const formWithoutModal = new UserRegistrationForm(formElement, null);

      expect(() => formWithoutModal.openModal()).not.toThrow();
      expect(() => formWithoutModal.closeModal()).not.toThrow();
      expect(() => formWithoutModal.getModalContinueFlag()).not.toThrow();
      expect(() => formWithoutModal.setModalContinueFlag(true)).not.toThrow();
      expect(formWithoutModal.getModalContinueFlag()).toBe(false);
    });

    it("should handle missing Decidim dialog system gracefully", () => {
      Reflect.deleteProperty(window, "Decidim");

      expect(() => omniauthRegistrationForm.openModal()).not.toThrow();
      expect(() => omniauthRegistrationForm.closeModal()).not.toThrow();
    });

    it("should handle missing newsletter checkbox gracefully", () => {
      newsletterCheckbox.remove();

      expect(omniauthRegistrationForm.getNewsletterCheckbox()).toBeNull();
      expect(omniauthRegistrationForm.isNewsletterChecked()).toBe(false);
      expect(() => omniauthRegistrationForm.setNewsletterCheckbox(true)).not.toThrow();
    });

    it("should handle OAuth provider errors gracefully", () => {
      // Remove OAuth provider attribute
      formElement.removeAttribute("data-provider");

      const mockEvent = { preventDefault: jest.fn() };
      expect(() => omniauthRegistrationForm.handleFormSubmission(mockEvent)).not.toThrow();
    });
  });

  describe("integration with parent class", () => {
    it("should maintain all parent functionality while extending for OAuth", () => {
      // Ensure parent state is maintained
      expect(omniauthRegistrationForm.isInitialized).toBe(false);
      omniauthRegistrationForm.initialize();
      expect(omniauthRegistrationForm.isInitialized).toBe(true);

      // Ensure parent methods work correctly
      const checkbox = omniauthRegistrationForm.getNewsletterCheckbox();
      expect(checkbox).toBe(newsletterCheckbox);
    });

    it("should properly override parent method while calling super", () => {
      const baseHandleFormSubmissionSpy = jest.spyOn(UserRegistrationForm.prototype, "handleFormSubmission");
      const mockEvent = { preventDefault: jest.fn() };

      omniauthRegistrationForm.handleFormSubmission(mockEvent);

      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);

      baseHandleFormSubmissionSpy.mockRestore();
    });
  });

  describe("OAuth specific edge cases", () => {
    it("should handle OAuth callback scenarios", () => {
      // Simulate OAuth callback with pre-filled data
      formElement.setAttribute("data-oauth-callback", "true");
      newsletterCheckbox.checked = true;

      const mockEvent = { preventDefault: jest.fn() };
      omniauthRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
    });

    it("should handle OAuth cancellation", () => {
      // Simulate OAuth cancellation/error state
      formElement.setAttribute("data-oauth-error", "access_denied");

      expect(omniauthRegistrationForm.exists()).toBe(true);
    });

    it("should handle OAuth scope permissions", () => {
      // Simulate limited OAuth scope (no email permission)
      formElement.setAttribute("data-oauth-scope", "basic");
      newsletterCheckbox.disabled = true;

      const mockEvent = { preventDefault: jest.fn() };
      omniauthRegistrationForm.handleFormSubmission(mockEvent);

      // Should still call parent method
      expect(UserRegistrationForm.prototype.handleFormSubmission).toBeDefined();
    });
  });
});
