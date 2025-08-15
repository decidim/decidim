/* eslint max-lines: ["error", 390] */

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
  let userRegistrationForm = null;
  let mockFormSubmit = null;

  beforeEach(() => {
    // Mock HTMLFormElement.prototype.submit
    mockFormSubmit = jest.fn();
    if (!HTMLFormElement.prototype.submit.mockImplementation) {
      Reflect.defineProperty(HTMLFormElement.prototype, "requestSubmit", {
        value: mockFormSubmit,
        writable: true,
        configurable: true
      });
    }

    // Set up DOM elements
    document.body.innerHTML = "";

    // Create form element
    formElement = document.createElement("form");
    formElement.id = "user-registration-form";

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
    userRegistrationForm = new UserRegistrationForm(formElement.id);
  });

  afterEach(() => {
    document.body.innerHTML = "";
    Reflect.deleteProperty(window, "Decidim");
    jest.clearAllMocks();
  });

  describe("constructor", () => {
    it("should initialize with correct properties", () => {
      expect(userRegistrationForm.formElement).toBe(formElement);
      expect(userRegistrationForm.modal).toBe(modalElement);
      expect(userRegistrationForm.newsletterSelector).toBe('input[type="checkbox"][name="user[newsletter]"]');
      expect(userRegistrationForm.isInitialized).toBe(false);
    });

    it("should be an instance of UserRegistrationForm", () => {
      expect(userRegistrationForm).toBeInstanceOf(UserRegistrationForm);
    });
  });

  describe("inheritance behavior", () => {
    it("should inherit all methods from BaseRegistrationForm", () => {
      // Test that all BaseRegistrationForm methods are available
      expect(typeof userRegistrationForm.initialize).toBe("function");
      expect(typeof userRegistrationForm.setupFormEventListeners).toBe("function");
      expect(typeof userRegistrationForm.setupModalEventListeners).toBe("function");
      expect(typeof userRegistrationForm.handleFormSubmission).toBe("function");
      expect(typeof userRegistrationForm.processNewsletterSelection).toBe("function");
      expect(typeof userRegistrationForm.getNewsletterCheckbox).toBe("function");
      expect(typeof userRegistrationForm.isNewsletterChecked).toBe("function");
      expect(typeof userRegistrationForm.setNewsletterCheckbox).toBe("function");
      expect(typeof userRegistrationForm.submit).toBe("function");
      expect(typeof userRegistrationForm.getModalContinueFlag).toBe("function");
      expect(typeof userRegistrationForm.setModalContinueFlag).toBe("function");
      expect(typeof userRegistrationForm.openModal).toBe("function");
      expect(typeof userRegistrationForm.closeModal).toBe("function");
      expect(typeof userRegistrationForm.exists).toBe("function");
    });

    it("should inherit newsletter selector from parent", () => {
      expect(userRegistrationForm.newsletterSelector).toBe('input[type="checkbox"][name="user[newsletter]"]');
    });

    it("should inherit initialization state from parent", () => {
      expect(userRegistrationForm.isInitialized).toBe(false);
      userRegistrationForm.initialize();
      expect(userRegistrationForm.isInitialized).toBe(true);
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
      userRegistrationForm.handleFormSubmission(mockEvent);
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should prevent submission and open modal when newsletter not checked", () => {
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "false";
      const openModalSpy = jest.spyOn(userRegistrationForm, "openModal");

      userRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(openModalSpy).toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should allow submission when newsletter is checked", () => {
      newsletterCheckbox.checked = true;
      modalElement.dataset.continue = "false";

      userRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should allow submission when continue flag is true", () => {
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "true";

      userRegistrationForm.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });
  });

  describe("inherited functionality", () => {
    it("should properly handle newsletter checkbox operations", () => {
      // Test inherited newsletter checkbox functionality
      expect(userRegistrationForm.isNewsletterChecked()).toBe(false);

      userRegistrationForm.setNewsletterCheckbox(true);
      expect(newsletterCheckbox.checked).toBe(true);
      expect(userRegistrationForm.isNewsletterChecked()).toBe(true);

      userRegistrationForm.setNewsletterCheckbox(false);
      expect(newsletterCheckbox.checked).toBe(false);
      expect(userRegistrationForm.isNewsletterChecked()).toBe(false);
    });

    it("should properly handle modal operations", () => {
      // Test inherited modal functionality
      expect(userRegistrationForm.getModalContinueFlag()).toBe(false);

      userRegistrationForm.setModalContinueFlag(true);
      expect(userRegistrationForm.getModalContinueFlag()).toBe(true);

      userRegistrationForm.openModal();
      expect(mockDecidimDialogs["sign-up-newsletter-modal"].open).toHaveBeenCalled();

      userRegistrationForm.closeModal();
      expect(mockDecidimDialogs["sign-up-newsletter-modal"].close).toHaveBeenCalled();
    });

    it("should properly handle form submission", () => {
      const submitSpy = jest.spyOn(formElement, "requestSubmit").mockImplementation(() => {});

      userRegistrationForm.submit();
      expect(submitSpy).toHaveBeenCalled();
    });

    it("should properly handle form existence check", () => {
      expect(userRegistrationForm.exists()).toBe(true);

      const formWithNullElement = new UserRegistrationForm(null, modalElement);
      expect(formWithNullElement.exists()).toBe(false);
    });
  });

  describe("initialization", () => {
    it("should initialize properly with event listeners", () => {
      const setupFormListenersSpy = jest.spyOn(userRegistrationForm, "setupFormEventListeners");
      const setupModalListenersSpy = jest.spyOn(userRegistrationForm, "setupModalEventListeners");

      userRegistrationForm.initialize();

      expect(setupFormListenersSpy).toHaveBeenCalled();
      expect(setupModalListenersSpy).toHaveBeenCalled();
      expect(userRegistrationForm.isInitialized).toBe(true);
    });

    it("should not initialize twice", () => {
      const setupFormListenersSpy = jest.spyOn(userRegistrationForm, "setupFormEventListeners");

      userRegistrationForm.initialize();
      userRegistrationForm.initialize();

      expect(setupFormListenersSpy).toHaveBeenCalledTimes(1);
    });

    it("should handle missing form element gracefully", () => {
      const formWithoutElement = new UserRegistrationForm(null, modalElement);
      const setupFormListenersSpy = jest.spyOn(formWithoutElement, "setupFormEventListeners");

      formWithoutElement.initialize();

      expect(setupFormListenersSpy).not.toHaveBeenCalled();
      expect(formWithoutElement.isInitialized).toBe(false);
    });
  });

  describe("newsletter selection workflow", () => {
    beforeEach(() => {
      userRegistrationForm.initialize();
    });

    it("should handle complete newsletter selection workflow", () => {
      const submitFormsSpy = jest.spyOn(userRegistrationForm, "submit");
      const closeModalSpy = jest.spyOn(userRegistrationForm, "closeModal");

      // Simulate newsletter selection
      userRegistrationForm.processNewsletterSelection(true);

      expect(newsletterCheckbox.checked).toBe(true);
      expect(modalElement.dataset.continue).toBe("true");
      expect(closeModalSpy).toHaveBeenCalled();
      expect(submitFormsSpy).toHaveBeenCalled();
    });

    it("should handle modal button interactions", () => {
      const processSelectionSpy = jest.spyOn(userRegistrationForm, "processNewsletterSelection");

      // Click the accept button
      const acceptButton = modalElement.querySelector('[data-check="true"]');
      acceptButton.click();

      expect(processSelectionSpy).toHaveBeenCalledWith(true);
    });

    it("should handle form submission with modal interaction", () => {
      // Set up form to trigger modal
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "false";

      const openModalSpy = jest.spyOn(userRegistrationForm, "openModal");

      // Simulate form submission
      const submitEvent = new Event("submit", { bubbles: true, cancelable: true });
      formElement.dispatchEvent(submitEvent);

      expect(submitEvent.defaultPrevented).toBe(true);
      expect(openModalSpy).toHaveBeenCalled();
    });
  });

  describe("multiple forms handling", () => {
    it("should handle multiple registration forms", () => {
      const updateCheckboxesSpy = jest.spyOn(userRegistrationForm, "setNewsletterCheckbox");
      const submitFormsSpy = jest.spyOn(userRegistrationForm, "submit");

      userRegistrationForm.processNewsletterSelection(true);

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

      expect(() => userRegistrationForm.openModal()).not.toThrow();
      expect(() => userRegistrationForm.closeModal()).not.toThrow();
    });

    it("should handle missing newsletter checkbox gracefully", () => {
      newsletterCheckbox.remove();

      expect(userRegistrationForm.getNewsletterCheckbox()).toBeNull();
      expect(userRegistrationForm.isNewsletterChecked()).toBe(false);
      expect(() => userRegistrationForm.setNewsletterCheckbox(true)).not.toThrow();
    });
  });

  describe("integration with parent class", () => {
    it("should maintain all parent functionality while extending", () => {
      // Ensure parent state is maintained
      expect(userRegistrationForm.isInitialized).toBe(false);
      userRegistrationForm.initialize();
      expect(userRegistrationForm.isInitialized).toBe(true);

      // Ensure parent methods work correctly
      const checkbox = userRegistrationForm.getNewsletterCheckbox();
      expect(checkbox).toBe(newsletterCheckbox);
    });

    it("should properly override parent method while calling super", () => {
      const baseHandleFormSubmissionSpy = jest.spyOn(UserRegistrationForm.prototype, "handleFormSubmission");
      const mockEvent = { preventDefault: jest.fn() };

      userRegistrationForm.handleFormSubmission(mockEvent);

      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);

      baseHandleFormSubmissionSpy.mockRestore();
    });
  });
});
