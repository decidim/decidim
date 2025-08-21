/* global jest */
/* eslint max-lines: ["error", 360] */
import { Application } from "@hotwired/stimulus"
import DeleteAccountFormController from "src/decidim/controllers/delete_account_form/controller";

describe("DeleteAccount", () => {
  let mockDeleteAccountForm = null;
  let mockDeleteAccountModalForm = null;
  let mockOpenModalButton = null;
  let mockReasonTextarea = null;
  let mockReasonInput = null;
  let application = null;
  let controller = null;

  beforeEach(() => {
    application = Application.start();
    application.register("delete-account-form", DeleteAccountFormController);
    // Set up DOM structure
    document.body.innerHTML = `
  <form data-controller="delete-account-form" data-live-validate="true" data-validate-on-blur="true" class="form-defaults delete-account" id="delete_user_edit_delete_account_1" novalidate="novalidate" action="/account" accept-charset="UTF-8" method="post">
    <input type="hidden" name="_method" value="delete" autocomplete="off" />
    <input type="hidden" name="authenticity_token" value="K1Dy_nKLQ4KwgIZIFddT_c__UrNlRJ2kDF_F48MKUfN-zBxDr_sc24OXRiWWJtQVkxhH7kmFmKE88TRxnNO6CQ" autocomplete="off" />
    <div class="form__wrapper">
      <label>
        <span class="help-text">Reason to delete your account</span>
        <textarea rows="2" name="delete_account[delete_reason]" id="delete_user_delete_account_delete_reason"></textarea>
      </label>
    </div>
    <div class="form__wrapper-block">
      <button type="button" data-dialog-open="delete-account" class="button button__sm md:button__lg button__secondary mr-auto !ml-0 open-modal-button"> Delete my account </button>
    </div>
  </form>
  <div id="delete-account" data-dialog="delete-account">
    <div id="delete-account-content" class="verification-modal">
      <button type="button" data-dialog-close="delete-account" data-dialog-closable="" aria-label="Close modal">&times</button>
      <form data-live-validate="true" data-validate-on-blur="true" class="delete-account-modal" id="delete_user_confirm_edit_delete_account_1" novalidate="novalidate" action="/account" accept-charset="UTF-8" method="post">
        <input type="hidden" name="_method" value="delete" autocomplete="off" />
        <input type="hidden" name="authenticity_token" value="WteUAxJawfORr3tuOkVF7UHKnAM6pl5n8ygK9ptPKnUPS3q-zyqeqqK4uwO5tMIFHS2JXhZnW2LDhvtkxJbBjw" autocomplete="off" />
        <input autocomplete="off" type="hidden" name="delete_account[delete_reason]" id="delete_user_confirm_delete_account_delete_reason" />
        <div data-dialog-container>
          <svg width="1em" height="1em" role="img" aria-hidden="true">
            <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-close-circle-line"></use>
          </svg>
          <h3 class="h3" id="dialog-title-delete-account" data-dialog-title> Are you sure you want to delete your account? </h3>
        </div>
        <div data-dialog-actions>
          <button type="button" class="button button__sm md:button__lg button__transparent-secondary" data-dialog-close="delete-account"> Close window </button>
          <input type="submit" class="button button__sm md:button__lg button__secondary" value="Yes, I want to delete my account">
        </div>
      </form>
    </div>
  </div>
    `;

    // Get references to DOM elements
    mockDeleteAccountForm = document.querySelector(".delete-account");
    mockDeleteAccountModalForm = document.querySelector(".delete-account-modal");
    mockOpenModalButton = document.querySelector(".open-modal-button");
    mockReasonTextarea = document.querySelector("#delete_user_delete_account_delete_reason");
    mockReasonInput = document.querySelector("#delete_user_confirm_delete_account_delete_reason");

    // Mock console.error
    jest.spyOn(console, "error").mockImplementation(() => {});

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(mockDeleteAccountForm, "delete-account-form");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    // Clean up
    document.body.innerHTML = "";
    console.error.mockRestore();
  });

  describe("constructor", () => {
    it("should initialize with correct DOM elements", () => {
      expect(controller.element).toBe(mockDeleteAccountForm);
      expect(controller.deleteAccountModalForm).toBe(mockDeleteAccountModalForm);
      expect(controller.openModalButton).toBe(mockOpenModalButton);
    });
  });

  describe("init()", () => {
    it("should call bindEvents when delete account form exists", () => {
      const bindEventsSpy = jest.spyOn(controller, "bindEvents");

      controller.disconnect()
      controller.connect()

      expect(bindEventsSpy).toHaveBeenCalled();
      bindEventsSpy.mockRestore();
    });
  });

  describe("bindEvents()", () => {
    it("should add click event listener to open modal button", () => {
      const addEventListenerSpy = jest.spyOn(mockOpenModalButton, "addEventListener");

      controller.disconnect()
      controller.connect()
      expect(addEventListenerSpy).toHaveBeenCalledWith("click", expect.any(Function));
      addEventListenerSpy.mockRestore();
    });

    it("should not add event listener when open modal button does not exist", () => {
      document.querySelector(".open-modal-button").remove();

      controller.disconnect()
      controller.connect()

      // Should not throw an error
      expect(controller.openModalButton).toBeNull();
    });
  });

  describe("handleModalOpen()", () => {
    it("should copy textarea value to hidden input", () => {
      const mockEvent = {
        preventDefault: jest.fn(),
        stopPropagation: jest.fn()
      };

      mockReasonTextarea.value = "User wants to delete account";
      const result = controller.handleModalOpen(mockEvent);

      expect(mockReasonInput.value).toBe("User wants to delete account");
      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(mockEvent.stopPropagation).toHaveBeenCalled();
      expect(result).toBe(false);
    });

    it("should handle empty textarea value", () => {
      const mockEvent = {
        preventDefault: jest.fn(),
        stopPropagation: jest.fn()
      };

      mockReasonTextarea.value = "";
      controller.handleModalOpen(mockEvent);

      expect(mockReasonInput.value).toBe("");
    });

    it("should handle case when textarea does not exist", () => {
      const mockEvent = {
        preventDefault: jest.fn(),
        stopPropagation: jest.fn()
      };

      mockReasonTextarea.remove();
      controller.handleModalOpen(mockEvent);

      expect(mockReasonInput.value).toBe("");
      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(mockEvent.stopPropagation).toHaveBeenCalled();
    });

    it("should handle case when input does not exist", () => {
      const mockEvent = {
        preventDefault: jest.fn(),
        stopPropagation: jest.fn()
      };

      mockReasonInput.remove();
      mockReasonTextarea.value = "Test reason";
      controller.handleModalOpen(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(mockEvent.stopPropagation).toHaveBeenCalled();
    });

    it("should handle errors gracefully", () => {
      const mockEvent = {
        preventDefault: jest.fn(),
        stopPropagation: jest.fn()
      };

      // Mock querySelector to throw an error
      const originalQuerySelector = controller.element.querySelector;
      controller.element.querySelector = jest.fn(() => {
        throw new Error("Test error");
      });

      controller.handleModalOpen(mockEvent);

      expect(console.error).toHaveBeenCalledWith(expect.any(Error));
      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(mockEvent.stopPropagation).toHaveBeenCalled();

      // Restore original method
      controller.element.querySelector = originalQuerySelector;
    });
  });

  describe("event integration", () => {
    it("should handle click event on open modal button", () => {
      mockReasonTextarea.value = "Integration test reason";

      const mockEvent = new Event("click", { bubbles: true, cancelable: true });
      const preventDefaultSpy = jest.spyOn(mockEvent, "preventDefault");
      const stopPropagationSpy = jest.spyOn(mockEvent, "stopPropagation");

      mockOpenModalButton.dispatchEvent(mockEvent);

      expect(mockReasonInput.value).toBe("Integration test reason");
      expect(preventDefaultSpy).toHaveBeenCalled();
      expect(stopPropagationSpy).toHaveBeenCalled();
    });
  });

});
