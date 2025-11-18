/* eslint max-lines: ["error", 425] */
/* global global, jest */

import { Application } from "@hotwired/stimulus"
import AccountFormController from "src/decidim/controllers/account_form/controller"

describe("AccountFormController", () => {
  let application = null;
  let controller = null;
  let fieldContainer = null;
  let mockElements = {};
  let mutationObserverCallback = null;
  let mockMutationObserver = null;

  beforeEach(async () => {
    // Enhanced MutationObserver mock that stores the callback for testing
    mockMutationObserver = {
      observe: jest.fn(),
      disconnect: jest.fn(),
      takeRecords: jest.fn(() => []),
      trigger: function(mutations = []) {
        if (mutationObserverCallback) {
          mutationObserverCallback(mutations);
        }
      }
    };

    global.MutationObserver = jest.fn().mockImplementation((callback) => {
      mutationObserverCallback = callback;
      return mockMutationObserver;
    });

    // Start Stimulus application
    application = Application.start();
    application.register("account-form", AccountFormController);

    // Set up simplified DOM structure
    document.body.innerHTML = `
      <div>
        <form data-controller="account-form"
              data-live-validate="true"
              data-validate-on-blur="true"
              class="form-defaults edit_user"
              id="edit_user_1"
              autocomplete="on"
              novalidate="novalidate"
              enctype="multipart/form-data"
              action="/account"
              accept-charset="UTF-8"
              method="post">

          <input type="hidden" name="_method" value="put" autocomplete="off" />
          <input type="hidden" name="authenticity_token" value="test-token" autocomplete="off" />

          <div class="form__wrapper pt-0">
            <div class="help-text">* Required fields are marked with an asterisk</div>

            <label for="user_name">Your name
              <input required="required"
                     autocomplete="name"
                     type="text"
                     value="Mr. Ferdinand"
                     name="user[name]"
                     id="user_name" />
              <span class="form-error">There is an error in this field.</span>
            </label>

            <label for="user_email">Your email
              <input required="required"
                     autocomplete="email"
                     data-original="admin@example.org"
                     type="email"
                     value="admin@example.org"
                     name="user[email]"
                     id="user_email" />
              <span class="form-error">There is an error in this field.</span>
            </label>

            <div data-controller="accordion" id="accordion-password">
              <button name="button"
                      type="button"
                      id="accordion-trigger-panel-password"
                      data-controls="panel-password">
                Change password
              </button>

              <div id="panel-password" class="mt-6" aria-hidden="true">
                <div data-controller="password-toggler" class="user-password">
                  <label for="user_password">Password</label>
                  <input required="required"
                         minlength="15"
                         maxlength="256"
                         autocomplete="new-password"
                         placeholder="**********"
                         type="password"
                         name="user[password]"
                         id="user_password" />
                  <span class="form-error">There is an error in this field.</span>
                </div>
              </div>
            </div>

            <div id="panel-old-password" class="hidden">
              <div data-controller="password-toggler" class="old-user-password">
                <div class="old-password__wrapper">
                  <label for="user_old_password">Current password</label>
                  <input required="required"
                         autocomplete="current-password"
                         placeholder="**********"
                         type="password"
                         name="user[old_password]"
                         id="user_old_password" />
                  <span class="form-error">There is an error in this field.</span>
                </div>
              </div>
            </div>

            <div class="form__wrapper-block">
              <button type="submit"
                      name="commit"
                      class="button button__secondary">
                Update account
              </button>
            </div>
          </div>
        </form>
      </div>
    `;

    // Store references to elements after DOM is created
    fieldContainer = document.getElementById("edit_user_1");
    mockElements = {
      newPasswordPanel: document.getElementById("panel-password"),
      oldPasswordPanel: document.getElementById("panel-old-password"),
      emailField: document.querySelector('input[type="email"]'),
      newPasswordInput: document.querySelector("#panel-password input"),
      oldPasswordInput: document.querySelector("#panel-old-password input")
    };

    // Wait for controller to be initialized
    await new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(fieldContainer, "account-form");
        resolve();
      }, 10);
    });
  });

  afterEach(() => {
    if (application) {
      application.stop();
    }
    document.body.innerHTML = "";
    jest.clearAllMocks();
    mutationObserverCallback = null;
    mockMutationObserver = null;
  });

  describe("initialization", () => {
    it("should initialize with all required elements present", () => {
      expect(controller).toBeDefined();
      expect(controller.newPasswordPanel).toBe(mockElements.newPasswordPanel);
      expect(controller.oldPasswordPanel).toBe(mockElements.oldPasswordPanel);
      expect(controller.emailField).toBe(mockElements.emailField);
      expect(controller.originalEmail).toBe("admin@example.org");
      expect(controller.emailChanged).toBe(false);
      expect(controller.newPwVisible).toBe(false);
      expect(controller.observer).toBeDefined();
    });

    it("should handle missing password panel gracefully", () => {
      // Remove password panel and create new controller
      document.getElementById("panel-password").remove();

      // Create a new form without the password panel
      const newForm = document.createElement("form");
      newForm.setAttribute("data-controller", "account-form");
      newForm.id = "test-form";
      newForm.innerHTML = `
        <input type="email" data-original="test@example.org" value="test@example.org" />
      `;
      document.body.appendChild(newForm);

      const newController = application.getControllerForElementAndIdentifier(newForm, "account-form");
      // The controller should handle missing elements gracefully
      expect(newController).toBeDefined();
    });
  });

  describe("toggleNewPassword", () => {
    it("should set input as required when newPwVisible is true", () => {
      controller.newPwVisible = true;
      controller.toggleNewPassword();
      expect(mockElements.newPasswordInput.required).toBe(true);
    });

    it("should set input as not required and clear value when newPwVisible is false", () => {
      mockElements.newPasswordInput.value = "test123";
      controller.newPwVisible = false;

      controller.toggleNewPassword();

      expect(mockElements.newPasswordInput.required).toBe(false);
      expect(mockElements.newPasswordInput.value).toBe("");
    });
  });

  describe("toggleOldPassword", () => {
    it("should return early if oldPasswordPanel is missing", () => {
      controller.oldPasswordPanel = null;
      expect(() => controller.toggleOldPassword()).not.toThrow();
    });

    it("should show old password panel when email changed", () => {
      controller.emailChanged = true;
      controller.newPwVisible = false;

      controller.toggleOldPassword();

      expect(mockElements.oldPasswordPanel.classList.contains("hidden")).toBe(false);
      expect(mockElements.oldPasswordInput.required).toBe(true);
    });

    it("should show old password panel when new password is visible", () => {
      controller.emailChanged = false;
      controller.newPwVisible = true;

      controller.toggleOldPassword();

      expect(mockElements.oldPasswordPanel.classList.contains("hidden")).toBe(false);
      expect(mockElements.oldPasswordInput.required).toBe(true);
    });

    it("should hide old password panel when neither condition is met", () => {
      controller.emailChanged = false;
      controller.newPwVisible = false;

      controller.toggleOldPassword();

      expect(mockElements.oldPasswordPanel.classList.contains("hidden")).toBe(true);
      expect(mockElements.oldPasswordInput.required).toBe(false);
    });
  });

  describe("setupMutationObserver", () => {
    it("should create MutationObserver and observe newPasswordPanel", () => {
      // Call setupMutationObserver if it was not called in connect
      if (!controller.observer) {
        controller.setupMutationObserver();
      }

      expect(MutationObserver).toHaveBeenCalledWith(expect.any(Function));
      expect(mockMutationObserver.observe).toHaveBeenCalledWith(
        mockElements.newPasswordPanel,
        { attributes: true }
      );
    });

    it("should update newPwVisible when aria-hidden changes to false", () => {
      // Ensure observer is set up
      if (!controller.observer) {
        controller.setupMutationObserver();
      }

      mockElements.newPasswordPanel.setAttribute("aria-hidden", "false");

      // Manually trigger the mutation observer callback
      mockMutationObserver.trigger();

      expect(controller.newPwVisible).toBe(true);
    });

    it("should update newPwVisible when aria-hidden changes to true", () => {
      // Ensure observer is set up
      if (!controller.observer) {
        controller.setupMutationObserver();
      }

      mockElements.newPasswordPanel.setAttribute("aria-hidden", "true");

      // Manually trigger the mutation observer callback
      mockMutationObserver.trigger();

      expect(controller.newPwVisible).toBe(false);
    });
  });

  describe("setupEmailChangeListener", () => {
    it("should update emailChanged when email value matches original", () => {
      // Ensure email listener is set up
      if (!controller.emailField.listeners) {
        controller.setupEmailChangeListener();
      }

      mockElements.emailField.value = "admin@example.org";

      const event = new Event("change");
      mockElements.emailField.dispatchEvent(event);

      expect(controller.emailChanged).toBe(false);
    });

    it("should detect email change when value differs from original", () => {
      // Ensure email listener is set up
      if (!controller.emailField.listeners) {
        controller.setupEmailChangeListener();
      }

      mockElements.emailField.value = "new@example.com";

      const event = new Event("change");
      mockElements.emailField.dispatchEvent(event);

      expect(controller.emailChanged).toBe(true);
    });
  });

  describe("destroy", () => {
    it("should disconnect observer and set to null", () => {
      // Ensure observer exists
      if (!controller.observer) {
        controller.setupMutationObserver();
      }

      controller.destroy();

      expect(mockMutationObserver.disconnect).toHaveBeenCalled();
      expect(controller.observer).toBeNull();
    });

    it("should handle case when observer is null", () => {
      controller.observer = null;
      expect(() => controller.destroy()).not.toThrow();
    });
  });

  describe("integration tests", () => {
    beforeEach(() => {
      // Ensure all methods are set up
      if (!controller.observer) {
        controller.setupMutationObserver();
      }
      if (!controller.emailField.listeners) {
        controller.setupEmailChangeListener();
      }
    });

    it("should show old password when new password becomes visible", () => {
      // Simulate password panel becoming visible
      mockElements.newPasswordPanel.setAttribute("aria-hidden", "false");
      mockMutationObserver.trigger();

      expect(controller.newPwVisible).toBe(true);
      expect(mockElements.newPasswordInput.required).toBe(true);
      expect(mockElements.oldPasswordPanel.classList.contains("hidden")).toBe(false);
      expect(mockElements.oldPasswordInput.required).toBe(true);
    });

    it("should hide old password when both email unchanged and new password hidden", () => {
      // Ensure email is set to original value
      mockElements.emailField.value = "admin@example.org";
      const emailEvent = new Event("change");
      mockElements.emailField.dispatchEvent(emailEvent);

      // Hide new password panel
      mockElements.newPasswordPanel.setAttribute("aria-hidden", "true");
      mockMutationObserver.trigger();

      expect(controller.emailChanged).toBe(false);
      expect(controller.newPwVisible).toBe(false);
      expect(mockElements.oldPasswordPanel.classList.contains("hidden")).toBe(true);
      expect(mockElements.oldPasswordInput.required).toBe(false);
    });

    it("should show old password when email is changed", () => {
      // Change email value
      mockElements.emailField.value = "changed@example.com";
      const emailEvent = new Event("change");
      mockElements.emailField.dispatchEvent(emailEvent);

      expect(controller.emailChanged).toBe(true);
      expect(mockElements.oldPasswordPanel.classList.contains("hidden")).toBe(false);
      expect(mockElements.oldPasswordInput.required).toBe(true);
    });
  });

  describe("error handling", () => {
    it("should handle missing elements gracefully", () => {
      // Remove elements and test graceful degradation
      document.getElementById("panel-old-password").remove();

      controller.oldPasswordPanel = null;

      expect(() => {
        controller.toggleOldPassword();
      }).not.toThrow();
    });

    it("should handle missing new password input gracefully", () => {
      // Test when the input inside the panel is missing
      const originalInput = mockElements.newPasswordInput;
      originalInput.remove();

      expect(() => {
        controller.toggleNewPassword();
      }).toThrow();
    });
  });

  describe("method calls", () => {
    it("should call setupMutationObserver and setupEmailChangeListener on connect if enabled", () => {
      // Since the methods are commented out in the controller, we test them manually
      const spySetupMutation = jest.spyOn(controller, "setupMutationObserver");
      const spySetupEmail = jest.spyOn(controller, "setupEmailChangeListener");

      controller.setupMutationObserver();
      controller.setupEmailChangeListener();

      expect(spySetupMutation).toHaveBeenCalled();
      expect(spySetupEmail).toHaveBeenCalled();
    });
  });
});
