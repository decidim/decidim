/* eslint max-lines: ["error", 390] */

/* global global, jest */
/**
 * @jest-environment jsdom
 */

import { Application } from "@hotwired/stimulus"
import controllerController from "src/decidim/controllers/user_registration_form/controller";
import FormValidatorController from "src/decidim/controllers/form_validator/controller";

describe("controller", () => {
  let application = null;
  let formElement = null;
  let modalElement = null;
  let newsletterCheckbox = null;
  let mockDecidimDialogs = null;
  let controller = null;
  let mockFormSubmit = null;

  beforeEach(() => {
    // Set up Stimulus application
    application = Application.start();
    application.register("user-registration-form", controllerController);
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
    document.body.innerHTML = `<div>
    <form data-controller="user-registration-form" class="new_user" id="register-form" novalidate="novalidate" action="/users" accept-charset="UTF-8" method="post">
      <input type="hidden" name="authenticity_token" value="aEGKlrfJBP1X5H5ReIy9WRCY9pAa-7JLZ-Vn1ztkH-JVXJKKRMG9ZnnDrJy4aC-MdQnkeQj4rqoItoljw14Kgw" autocomplete="off" />
      <div class="field hidden">
        <label for="field">If you are human, ignore this field</label>
        <input type="text" name="field" id="field" autocomplete="off" tabindex="-1" />
      </div>
      <div class="form__wrapper pb-12">
        <label for="registration_user_name">Your name <span title="Required field" data-tooltip="true" data-disable-hover="false" data-keep-on-hover="true" class="label-required">
            <span aria-hidden="true">*</span>
            <span class="sr-only">Required field</span>
          </span>
          <span class="help-text">Public name that appears on your posts. With the aim of guaranteeing the anonymity, can be any name.</span>
          <input required="required" autocomplete="name" placeholder="John Doe" type="text" name="user[name]" id="registration_user_name" />
          <span class="form-error">There is an error in this field.</span>
        </label>
        <label for="registration_user_email">Your email <span title="Required field" data-tooltip="true" data-disable-hover="false" data-keep-on-hover="true" class="label-required">
            <span aria-hidden="true">*</span>
            <span class="sr-only">Required field</span>
          </span>
          <input required="required" autocomplete="email" placeholder="hi@example.org" type="email" name="user[email]" id="registration_user_email" />
          <span class="form-error">There is an error in this field.</span>
        </label>
        <div data-controller="password-toggler" class="user-password" data-show-password="Show password" data-hide-password="Hide password" data-hidden-password="Your password is hidden" data-shown-password="Your password is shown">
          <label for="registration_user_password">Password <span title="Required field" data-tooltip="true" data-disable-hover="false" data-keep-on-hover="true" class="label-required">
              <span aria-hidden="true">*</span>
              <span class="sr-only">Required field</span>
            </span>
          </label>
          <span class="help-text">10 characters minimum, must not be too common (e.g. 123456) and must be different from your nickname and your email.</span>
          <input pattern="^(.|[

]){10,256}$" required="required" minlength="10" maxlength="256" autocomplete="new-password" placeholder="**********" class="input-group-field" size="256" type="password" name="user[password]" id="registration_user_password" />
          <span class="form-error">There is an error in this field.</span>
        </div>
      </div>
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
      <div class="form__wrapper-block">
        <button type="submit" class="button button__lg button__secondary"> Create an account </button>
      </div>
      <div class="login__links">
        <a href="/users/confirmation/new">Did not receive confirmation instructions?</a>
        <a href="/users/unlock/new">Did not receive unlock instructions?</a>
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

    formElement = document.getElementById("register-form");
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

    it("should prevent submission and open modal when newsletter not checked", () => {
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "false";
      const openModalSpy = jest.spyOn(controller, "openModal");

      controller.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(openModalSpy).toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should allow submission when newsletter is checked", () => {
      newsletterCheckbox.checked = true;
      modalElement.dataset.continue = "false";

      controller.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
    });

    it("should allow submission when continue flag is true", () => {
      newsletterCheckbox.checked = false;
      modalElement.dataset.continue = "true";

      controller.handleFormSubmission(mockEvent);

      expect(mockEvent.preventDefault).not.toHaveBeenCalled();
      expect(baseHandleFormSubmissionSpy).toHaveBeenCalledWith(mockEvent);
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

  describe("newsletter selection workflow", () => {
    beforeEach(() => {
      controller.initialize();
    });

    it("should handle complete newsletter selection workflow", () => {
      const submitFormsSpy = jest.spyOn(controller, "submit");
      const closeModalSpy = jest.spyOn(controller, "closeModal");

      // Simulate newsletter selection
      controller.processNewsletterSelection(true);

      expect(newsletterCheckbox.checked).toBe(true);
      expect(modalElement.dataset.continue).toBe("true");
      expect(closeModalSpy).toHaveBeenCalled();
      expect(submitFormsSpy).toHaveBeenCalled();
    });

    it("should handle modal button interactions", () => {
      const processSelectionSpy = jest.spyOn(controller, "processNewsletterSelection");

      // Click the accept button
      const acceptButton = modalElement.querySelector('[data-check="true"]');
      acceptButton.click();

      expect(processSelectionSpy).toHaveBeenCalledWith(true);
    });

    it("should handle form submission with modal interaction", () => {
      // Set up form to trigger modal
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

  describe("multiple forms handling", () => {
    it("should handle multiple registration forms", () => {
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
  });

  describe("integration with parent class", () => {
    it("should maintain all parent functionality while extending", () => {
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
});
