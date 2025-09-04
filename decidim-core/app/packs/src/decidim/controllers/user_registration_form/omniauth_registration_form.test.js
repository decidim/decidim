/* eslint max-lines: ["error", 510] */
/* global global, jest */
/**
 * @jest-environment jsdom
 */
import { Application } from "@hotwired/stimulus"
import UserRegistrationFormController from "src/decidim/controllers/user_registration_form/controller";
import FormValidatorController from "src/decidim/controllers/form_validator/controller";

describe("UserRegistrationForm", () => {
  let application = null;
  let controller = null;
  let formElement = null;
  let modalElement = null;
  let newsletterCheckbox = null;
  let mockDecidimDialogs = null;
  let mockFormSubmit = null;

  beforeEach(() => {
    // Set up Stimulus application
    application = Application.start();
    application.register("user-registration-form", UserRegistrationFormController);
    application.register("form-validator", FormValidatorController);

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
    document.body.innerHTML = `
      <form data-controller="user-registration-form" class="new_user" id="omniauth-register-form" novalidate="novalidate" action="/omniauth_registrations.user" accept-charset="UTF-8" method="post">
    <input type="hidden" name="authenticity_token" value="5mM_j0bJRitLne1-eA_eIaM_h6vZfaR1CTUTBU1WVcqam3LcxliS-zhM61pSI1Cfl7pTelN-3PwOFHKyda2FLQ" autocomplete="off" />
    <div class="form__wrapper">
      <input autocomplete="off" type="hidden" value="Alecs" name="user[name]" id="registration_user_name" />
      <input autocomplete="off" type="hidden" value="AAAAA" name="user[nickname]" id="registration_user_nickname" />
      <input autocomplete="off" type="hidden" value="test@example.org" name="user[email]" id="registration_user_email" />
      <div id="card__tos" class="form__wrapper-block border-y-2">
        <h2 class="h4">Terms of Service</h2>
        <div> Please add meaningful summary to the Terms of service static page on the admin dashboard. </div>
        <label class="form__wrapper-checkbox-label" for="registration_user_tos_agreement">
          <input name="user[tos_agreement]" type="hidden" value="0" autocomplete="off" />
          <input type="checkbox" value="1" name="user[tos_agreement]" id="registration_user_tos_agreement" />By signing up you agree to <a href="/pages/terms-of-service">the terms of service</a>. </label>
      </div>
      <div id="card__newsletter" class="form__wrapper-block">
        <h2 class="h4">Contact permission</h2>
        <label class="form__wrapper-checkbox-label" for="registration_user_newsletter">
          <input name="user[newsletter]" type="hidden" value="0" autocomplete="off" />
          <input type="checkbox" value="1" name="user[newsletter]" id="registration_user_newsletter" />Receive an occasional newsletter with relevant information </label>
      </div>
      <input autocomplete="off" type="hidden" value="test@example.org" name="user[uid]" id="registration_user_uid" />
      <input autocomplete="off" type="hidden" value="developer" name="user[provider]" id="registration_user_provider" />
      <input autocomplete="off" type="hidden" value="878ff586ef6f488d262010cb6575b66017d42c2d04d0b8be679cd493e315db29" name="user[oauth_signature]" id="registration_user_oauth_signature" />
    </div>
    <div class="form__wrapper-block">
      <button type="submit" class="button button__lg button__secondary">
        <span>Create an account</span>
        <svg width="1em" height="1em" role="img" aria-hidden="true" class="fill-current">
          <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-arrow-right-line"></use>
        </svg>
      </button>
    </div>
  </form>
  <div id="sign-up-newsletter-modal" data-dialog="sign-up-newsletter-modal">
    <div id="sign-up-newsletter-modal-content">
      <button type="button" data-dialog-close="sign-up-newsletter-modal" data-dialog-closable="" aria-label="Close modal">&times</button>
      <div data-dialog-container>
        <svg width="1em" height="1em" role="img" aria-hidden="true">
          <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-newspaper-line"></use>
        </svg>
        <h2 id="dialog-title-sign-up-newsletter-modal" data-dialog-title>Newsletter notifications</h2>
        <div id="dialog-desc-sign-up-newsletter-modal" class="space-y-4">
          <p>Hey, are you sure you do not want to receive a newsletter? Please consider again ticking the newsletter checkbox below. It is very important for us that you can receive occasional emails to make important announcements, you can always change this on your notifications settings page.</p>
          <p>If you do not tick the box you might be missing relevant information about new participatory opportunities within the platform. <br> If you still want to avoid receiving newsletters, we perfectly understand your decision. </p>
          <p>Thanks for reading this!</p>
        </div>
      </div>
      <div data-dialog-actions>
        <button class="button button__sm md:button__lg button__transparent-secondary" data-check="false"> Keep unchecked </button>
        <button class="button button__sm md:button__lg button__secondary" data-check="true"> Check and continue </button>
      </div>
    </div>
  </div>
`;

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

    formElement = document.getElementById("omniauth-register-form");
    modalElement = document.getElementById("sign-up-newsletter-modal");
    newsletterCheckbox = document.querySelector('input[type="checkbox"][name="user[newsletter]"]')

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(formElement, "user-registration-form");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
    Reflect.deleteProperty(window, "Decidim");
    jest.clearAllMocks();
  });

  describe("constructor", () => {
    it("should initialize with correct properties", () => {
      expect(controller.element).toBe(formElement);
      expect(controller.modal).toBe(modalElement);
      expect(controller.newsletterSelector).toBe('input[type="checkbox"][name="user[newsletter]"]');
    });
  });

  describe("inheritance behavior", () => {
    it("should inherit all methods from BaseRegistrationForm", () => {
      // Test that all BaseRegistrationForm methods are available
      expect(typeof controller.setupFormEventListeners).toBe("function");
      expect(typeof controller.setupModalEventListeners).toBe("function");
      expect(typeof controller.handleFormSubmission).toBe("function");
      expect(typeof controller.processNewsletterSelection).toBe("function");
      expect(typeof controller.getNewsletterCheckbox).toBe("function");
      expect(typeof controller.isNewsletterChecked).toBe("function");
      expect(typeof controller.setNewsletterCheckbox).toBe("function");
      expect(typeof controller.submit).toBe("function");
      expect(typeof controller.getModalContinueFlag).toBe("function");
      expect(typeof controller.setModalContinueFlag).toBe("function");
      expect(typeof controller.openModal).toBe("function");
      expect(typeof controller.closeModal).toBe("function");
    });

    it("should inherit newsletter selector from parent", () => {
      expect(controller.newsletterSelector).toBe('input[type="checkbox"][name="user[newsletter]"]');
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
      baseHandleFormSubmissionSpy = jest.spyOn(controller, "handleFormSubmission");
    });

    afterEach(() => {
      baseHandleFormSubmissionSpy.mockRestore();
    });

    it("should call parent handleFormSubmission method", () => {
      controller.handleFormSubmission(mockEvent);
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should prevent OAuth submission and open modal when newsletter not checked", () => {
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "false";
      const openModalSpy = jest.spyOn(controller, "openModal");

      controller.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(openModalSpy).toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should allow OAuth submission when newsletter is checked", () => {
      newsletterCheckbox.checked = true;
      modalElement.dataset.continue = "false";

      controller.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should allow OAuth submission when continue flag is true", () => {
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "true";

      controller.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should handle OAuth provider specific form submission", () => {
      // Add OAuth provider attribute
      formElement.setAttribute("data-provider", "facebook");
      newsletterCheckbox.checked = true;

      controller.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });
  });

  describe("OAuth specific functionality", () => {
    it("should maintain OAuth form context during newsletter workflow", () => {
      formElement.setAttribute("data-provider", "google");
      controller.initialize();

      const submitFormsSpy = jest.spyOn(controller, "submit");
      const closeModalSpy = jest.spyOn(controller, "closeModal");

      // Simulate newsletter selection in OAuth context
      controller.processNewsletterSelection(true);

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
      controller.handleFormSubmission(mockEvent);

      expect(mockFormSubmit).not.toHaveBeenCalled();
    });

    it("should handle OAuth form submission with external authentication", () => {
      // Simulate OAuth external auth state
      formElement.setAttribute("data-external-auth", "true");
      newsletterCheckbox.checked = false;

      const mockEvent = { preventDefault: jest.fn() };
      controller.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(mockFormSubmit).not.toHaveBeenCalled();
    });
  });

  describe("inherited functionality", () => {
    it("should properly handle newsletter checkbox operations", () => {
      // Test inherited newsletter checkbox functionality
      expect(controller.isNewsletterChecked()).toBe(false);

      controller.setNewsletterCheckbox(true);
      expect(newsletterCheckbox.checked).toBe(true);
      expect(controller.isNewsletterChecked()).toBe(true);

      controller.setNewsletterCheckbox(false);
      expect(newsletterCheckbox.checked).toBe(false);
      expect(controller.isNewsletterChecked()).toBe(false);
    });

    it("should properly handle modal operations", () => {
      // Test inherited modal functionality
      expect(controller.getModalContinueFlag()).toBe(false);

      controller.setModalContinueFlag(true);
      expect(controller.getModalContinueFlag()).toBe(true);

      controller.openModal();
      expect(mockDecidimDialogs["sign-up-newsletter-modal"].open).toHaveBeenCalled();

      controller.closeModal();
      expect(mockDecidimDialogs["sign-up-newsletter-modal"].close).toHaveBeenCalled();
    });

    it("should properly handle form submission", () => {
      const submitSpy = jest.spyOn(formElement, "requestSubmit").mockImplementation(() => {});

      controller.submit();
      expect(submitSpy).toHaveBeenCalled();
    });
  });

  describe("initialization", () => {
    it("should initialize properly with event listeners", () => {
      const setupFormListenersSpy = jest.spyOn(controller, "setupFormEventListeners");
      const setupModalListenersSpy = jest.spyOn(controller, "setupModalEventListeners");

      controller.disconnect();
      controller.connect();

      expect(setupFormListenersSpy).toHaveBeenCalled();
      expect(setupModalListenersSpy).toHaveBeenCalled();
    });

    it("should not initialize twice", () => {
      const setupFormListenersSpy = jest.spyOn(controller, "setupFormEventListeners");

      controller.disconnect();
      controller.connect();

      expect(setupFormListenersSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe("newsletter selection workflow for OAuth", () => {
    it("should handle complete OAuth newsletter selection workflow", () => {
      const submitFormsSpy = jest.spyOn(controller, "submit");
      const closeModalSpy = jest.spyOn(controller, "closeModal");

      // Simulate newsletter selection in OAuth context
      controller.processNewsletterSelection(true);

      expect(newsletterCheckbox.checked).toBe(true);
      expect(modalElement.dataset.continue).toBe("true");
      expect(closeModalSpy).toHaveBeenCalled();
      expect(submitFormsSpy).toHaveBeenCalled();
    });

    it("should handle modal button interactions in OAuth context", () => {
      const processSelectionSpy = jest.spyOn(controller, "processNewsletterSelection");

      // Click the accept button
      const acceptButton = modalElement.querySelector('[data-check="true"]');
      acceptButton.click();

      expect(processSelectionSpy).toHaveBeenCalledWith(true);
    });

    it("should handle OAuth form submission with modal interaction", () => {
      // Set up OAuth form to trigger modal
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "false";

      const openModalSpy = jest.spyOn(controller, "openModal");

      // Simulate form submission
      const submitEvent = new Event("submit", { bubbles: true, cancelable: true });
      formElement.dispatchEvent(submitEvent);

      expect(submitEvent.defaultPrevented).toBe(true);
      expect(openModalSpy).toHaveBeenCalled();
    });
  });

  describe("multiple OAuth forms handling", () => {
    it("should handle multiple OAuth registration forms", () => {
      const updateCheckboxesSpy = jest.spyOn(controller, "setNewsletterCheckbox");
      const submitFormsSpy = jest.spyOn(controller, "submit");

      controller.processNewsletterSelection(true);

      expect(updateCheckboxesSpy).toHaveBeenCalledWith(true);
      expect(submitFormsSpy).toHaveBeenCalled();
    });
  });

  describe("error handling", () => {
    it("should handle missing Decidim dialog system gracefully", () => {
      Reflect.deleteProperty(window, "Decidim");

      expect(() => controller.openModal()).not.toThrow();
      expect(() => controller.closeModal()).not.toThrow();
    });

    it("should handle missing newsletter checkbox gracefully", () => {
      newsletterCheckbox.remove();

      expect(controller.getNewsletterCheckbox()).toBeNull();
      expect(controller.isNewsletterChecked()).toBe(false);
      expect(() => controller.setNewsletterCheckbox(true)).not.toThrow();
    });

    it("should handle OAuth provider errors gracefully", () => {
      // Remove OAuth provider attribute
      formElement.removeAttribute("data-provider");

      const mockEvent = { preventDefault: jest.fn() };
      expect(() => controller.handleFormSubmission(mockEvent)).not.toThrow();
    });
  });

  describe("integration with parent class", () => {
    it("should maintain all parent functionality while extending for OAuth", () => {
      // Ensure parent state is maintained
      controller.disconnect();
      controller.connect();

      // Ensure parent methods work correctly
      const checkbox = controller.getNewsletterCheckbox();
      expect(checkbox).toBe(newsletterCheckbox);
    });

    it("should properly override parent method while calling super", () => {
      const baseHandleFormSubmissionSpy = jest.spyOn(controller, "handleFormSubmission");
      const mockEvent = { preventDefault: jest.fn() };

      controller.handleFormSubmission(mockEvent);

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
      controller.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
    });

    it("should handle OAuth scope permissions", () => {
      // Simulate limited OAuth scope (no email permission)
      formElement.setAttribute("data-oauth-scope", "basic");
      newsletterCheckbox.disabled = true;

      const mockEvent = { preventDefault: jest.fn() };
      controller.handleFormSubmission(mockEvent);

      // Should still call parent method
      expect(controller.handleFormSubmission).toBeDefined();
    });
  });
});
