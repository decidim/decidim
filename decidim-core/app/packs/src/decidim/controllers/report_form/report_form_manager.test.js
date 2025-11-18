/* eslint max-lines: ["error", 700] */
/* global jest */
/**
 * @jest-environment jsdom
 */
import { Application } from "@hotwired/stimulus"
import ReportFormController from "src/decidim/controllers/report_form/controller";

describe("ReportFormManager", () => {
  let application = null;
  let controller = null;
  let formElement = null;
  let consoleErrorSpy = null;
  let consoleWarnSpy = null;

  beforeEach(() => {
    // Set up Stimulus application
    application = Application.start();
    application.register("report-form", ReportFormController);

    // Mock console methods
    consoleErrorSpy = jest.spyOn(console, "error").mockImplementation(() => {});
    consoleWarnSpy = jest.spyOn(console, "warn").mockImplementation(() => {});

    // Create DOM structure based on actual report user modal form
    document.body.innerHTML = `
      <form class="new_report" data-controller="report-form" action="/report_user" accept-charset="UTF-8" method="post">
        <input type="hidden" name="authenticity_token" value="test_token" autocomplete="off" />
        <div data-dialog-container>
          <svg width="1em" height="1em" role="img" aria-hidden="true">
            <use href="/decidim-packs/media/images/remixicon.symbol.svg#ri-flag-line"></use>
          </svg>
          <h2 tabindex="-1" data-dialog-title>Report inappropriate participant</h2>
          <div>
            <div class="form__wrapper flag-modal__form">
              <p class="flag-modal__form-description">What is inappropriate about this participant?</p>
              <fieldset class="mt-6">
                <legend class="flag-modal__form-reason">Reason:</legend>
                <input type="hidden" name="report[reason]" value="" autocomplete="off" />
                <label for="spam-flagUserModal" class="form__wrapper-checkbox-label">
                  <input id="spam-flagUserModal" type="radio" value="spam" checked="checked" name="report[reason]" />
                  Contains clickbait, advertising, scams or script bots.
                </label>
                <label for="offensive-flagUserModal" class="form__wrapper-checkbox-label">
                  <input id="offensive-flagUserModal" type="radio" value="offensive" name="report[reason]" />
                  Contains racism, sexism, slurs, personal attacks, death threats, suicide requests or any form of hate speech.
                </label>
                <label for="does_not_belong-flagUserModal" class="form__wrapper-checkbox-label">
                  <input id="does_not_belong-flagUserModal" type="radio" value="does_not_belong" name="report[reason]" />
                  Contains illegal activity, suicide threats, personal information, or something else you think does not belong on Organization.
                </label>
              </fieldset>
              <label class="flag-modal__form-textarea-label" for="additional-comments-flagUserModal">
                Additional comments
                <textarea rows="4" id="additional-comments-flagUserModal" name="report[details]"></textarea>
              </label>

              <label for="report_block">
                <input data-label-action="Block this participant"
                       data-label-report="Report"
                       data-block="true"
                       type="checkbox"
                       value="1"
                       name="report[block]"
                       id="report_block" />
                Block this participant
              </label>
              <label class="invisible" id="block_and_hide" for="report_hide">
                <input name="report[hide]" type="hidden" value="0" autocomplete="off" />
                <input type="checkbox" value="1" name="report[hide]" id="report_hide" />
                Hide all their contents
              </label>
            </div>
          </div>
        </div>

        <div data-dialog-actions>
          <button type="button" class="button button__lg button__transparent-secondary" data-dialog-close="flagUserModal">
            Cancel
          </button>

          <button type="submit" class="button button__lg button__secondary">
            <span>Report</span>
            <svg width="1em" height="1em" role="img" aria-hidden="true" class="fill-current">
              <use href="/decidim-packs/media/images/remixicon.symbol.svg#ri-arrow-right-line"></use>
            </svg>
          </button>
        </div>
      </form>
    `;

    formElement = document.querySelector('[data-controller="report-form"]');
    // Wait for the controller to be connected
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(formElement, "report-form");
        resolve();
      }, 0);
    });

  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
    consoleErrorSpy.mockRestore();
    consoleWarnSpy.mockRestore();
    jest.clearAllMocks();
  });

  describe("constructor", () => {
    it("creates instance with default options", () => {

      expect(controller.element).toBe(formElement);
      expect(controller.options.hideSelector).toBe('[data-hide="true"]');
      expect(controller.options.blockSelector).toBe('[data-block="true"]');
      expect(controller.options.blockAndHideSelector).toBe("#block_and_hide");
      expect(controller.options.submitSelector).toBe('button[type="submit"]');
      expect(controller.isInitialized).toBe(true);
    });

    it("does not initialize twice", () => {
      const firstInitialized = controller.isInitialized;

      // Try to initialize again
      controller.disconnect();
      controller.connect();

      expect(firstInitialized).toBe(true);
      expect(controller.isInitialized).toBe(true);
    });
  });

  describe("block checkbox functionality", () => {
    it("sets up event listeners for block checkboxes", () => {
      const blockCheckboxes = document.querySelectorAll('[data-block="true"]');

      expect(blockCheckboxes.length).toBe(1);
      expect(controller.eventListeners.size).toBeGreaterThanOrEqual(1);
    });

    it("changes submit button label when block checkbox is checked", () => {
      const blockCheckbox = document.getElementById("report_block");
      const submitButton = document.querySelector("button[type=submit] span");

      expect(submitButton.textContent).toBe("Report");

      // Check the checkbox
      blockCheckbox.checked = true;
      blockCheckbox.dispatchEvent(new Event("change"));

      expect(submitButton.textContent).toBe("Block this participant");
    });

    it("reverts submit button label when block checkbox is unchecked", () => {
      const blockCheckbox = document.getElementById("report_block");
      const submitButton = document.querySelector("button[type=submit] span");

      // Check the checkbox first
      blockCheckbox.checked = true;
      blockCheckbox.dispatchEvent(new Event("change"));
      expect(submitButton.textContent).toBe("Block this participant");

      // Uncheck the checkbox
      blockCheckbox.checked = false;
      blockCheckbox.dispatchEvent(new Event("change"));

      expect(submitButton.textContent).toBe("Report");
    });

    it("toggles block and hide element visibility", () => {
      const blockCheckbox = document.getElementById("report_block");
      const blockAndHideElement = document.getElementById("block_and_hide");

      expect(blockAndHideElement.classList.contains("invisible")).toBe(true);

      // Check the checkbox
      blockCheckbox.checked = true;
      blockCheckbox.dispatchEvent(new Event("change"));

      expect(blockAndHideElement.classList.contains("invisible")).toBe(false);

      // Uncheck the checkbox
      blockCheckbox.checked = false;
      blockCheckbox.dispatchEvent(new Event("change"));

      expect(blockAndHideElement.classList.contains("invisible")).toBe(true);
    });
  });

  describe("hide checkbox functionality", () => {
    beforeEach(() => {
      // Add hide checkbox with proper data attributes for testing
      const hideCheckbox = document.createElement("input");
      hideCheckbox.type = "checkbox";
      hideCheckbox.id = "test_hide_checkbox";
      hideCheckbox.dataset.hide = "true";
      hideCheckbox.dataset.labelAction = "Hide content";
      hideCheckbox.dataset.labelReport = "Report content";

      const hideLabel = document.createElement("label");
      hideLabel.htmlFor = "test_hide_checkbox";
      hideLabel.appendChild(hideCheckbox);
      hideLabel.appendChild(document.createTextNode("Hide this content"));

      document.querySelector(".form__wrapper").appendChild(hideLabel);

      // Re-initialize to pick up the new checkbox
      controller.disconnect();
      controller.connect();
    });

    it("sets up event listeners for hide checkboxes", () => {
      const hideCheckboxes = document.querySelectorAll('[data-hide="true"]');

      expect(hideCheckboxes.length).toBe(1);
    });

    it("changes submit button label when hide checkbox is checked", () => {
      const hideCheckbox = document.getElementById("test_hide_checkbox");
      const submitButton = document.querySelector("button[type=submit] span");

      expect(submitButton.textContent).toBe("Report");

      // Check the checkbox
      hideCheckbox.checked = true;
      hideCheckbox.dispatchEvent(new Event("change"));

      expect(submitButton.textContent).toBe("Hide content");
    });

    it("reverts submit button label when hide checkbox is unchecked", () => {
      const hideCheckbox = document.getElementById("test_hide_checkbox");
      const submitButton = document.querySelector("button[type=submit] span");

      // Check the checkbox first
      hideCheckbox.checked = true;
      hideCheckbox.dispatchEvent(new Event("change"));
      expect(submitButton.textContent).toBe("Hide content");

      // Uncheck the checkbox
      hideCheckbox.checked = false;
      hideCheckbox.dispatchEvent(new Event("change"));

      expect(submitButton.textContent).toBe("Report content");
    });
  });

  describe("submit button detection", () => {

    it("finds submit button with nested span", () => {
      const form = controller.element;
      const submitElement = controller.findSubmitButton(form);

      expect(submitElement.tagName).toBe("SPAN");
      expect(submitElement.textContent).toBe("Report");
    });

    it("finds submit button without nested span", () => {
      // Create form with button without nested span
      const formWithoutSpan = document.createElement("form");
      const buttonWithoutSpan = document.createElement("button");
      buttonWithoutSpan.type = "submit";
      buttonWithoutSpan.textContent = "Submit";
      formWithoutSpan.appendChild(buttonWithoutSpan);
      document.body.appendChild(formWithoutSpan);

      const submitElement = controller.findSubmitButton(formWithoutSpan);

      expect(submitElement.tagName).toBe("BUTTON");
      expect(submitElement.textContent).toBe("Submit");
    });

    it("returns null when no submit button found", () => {
      const formWithoutSubmit = document.createElement("form");
      const regularButton = document.createElement("button");
      regularButton.type = "button";
      formWithoutSubmit.appendChild(regularButton);

      const submitElement = controller.findSubmitButton(formWithoutSubmit);

      expect(submitElement).toBeNull();
    });
  });

  describe("error handling", () => {
    it("handles checkbox outside of form gracefully", () => {
      // Create checkbox outside of form
      const isolatedCheckbox = document.createElement("input");
      isolatedCheckbox.type = "checkbox";
      isolatedCheckbox.dataset.block = "true";
      isolatedCheckbox.dataset.labelAction = "Block";
      isolatedCheckbox.dataset.labelReport = "Report";
      document.body.appendChild(isolatedCheckbox);

      controller.handleCheckboxChange(isolatedCheckbox);

      expect(consoleWarnSpy).toHaveBeenCalledWith("Checkbox is not within a form element");
    });

    it("handles form without submit button gracefully", () => {
      const formWithoutSubmit = document.createElement("form");
      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.dataset.block = "true";
      checkbox.dataset.labelAction = "Block";
      checkbox.dataset.labelReport = "Report";
      formWithoutSubmit.appendChild(checkbox);
      controller.element.appendChild(formWithoutSubmit);

      controller.handleCheckboxChange(checkbox);

      expect(consoleWarnSpy).toHaveBeenCalledWith("No submit button found in form");
    });

    it("handles checkbox without required data attributes gracefully", () => {
      const checkbox = document.getElementById("report_block");
      Reflect.deleteProperty(checkbox.dataset, "labelAction");
      Reflect.deleteProperty(checkbox.dataset, "labelReport");

      const submitButton = document.querySelector("button[type=submit] span");
      controller.updateSubmitButtonLabel(submitButton, checkbox);

      expect(consoleWarnSpy).toHaveBeenCalledWith(
        "Checkbox is missing required data attributes (data-label-action, data-label-report)"
      );
    });

    it("handles errors during checkbox change gracefully", () => {
      const checkbox = document.getElementById("report_block");

      // Mock closest to throw an error
      const originalClosest = checkbox.closest;
      checkbox.closest = () => {
        throw new Error("DOM error");
      };

      controller.handleCheckboxChange(checkbox);

      expect(consoleErrorSpy).toHaveBeenCalledWith("Error handling checkbox change:", expect.any(Error));

      // Restore original method
      checkbox.closest = originalClosest;
    });

    it("handles errors during block and hide visibility toggle gracefully", () => {
      const blockCheckbox = document.getElementById("report_block");

      // Mock closest to throw an error
      const originalClosest = blockCheckbox.closest;
      blockCheckbox.closest = () => {
        throw new Error("DOM error");
      };

      controller.toggleBlockAndHideVisibility(blockCheckbox);

      expect(consoleErrorSpy).toHaveBeenCalledWith("Error toggling block and hide visibility:", expect.any(Error));

      // Restore original method
      blockCheckbox.closest = originalClosest;
    });
  });

  describe("destroy method", () => {
    it("removes all event listeners", () => {
      const initialListenerCount = controller.eventListeners.size;
      expect(initialListenerCount).toBeGreaterThan(0);

      controller.disconnect();

      expect(controller.eventListeners.size).toBe(0);
    });

    it("resets initialization state", () => {
      expect(controller.isInitialized).toBe(true);

      controller.disconnect();

      expect(controller.isInitialized).toBe(false);
    });

    it("handles cleanup errors gracefully", () => {
      // Mock eventListeners.forEach to throw an error
      controller.eventListeners.forEach = () => {
        throw new Error("Cleanup error");
      };

      controller.disconnect();

      expect(consoleErrorSpy).toHaveBeenCalledWith("Error during ReportFormManager cleanup:", expect.any(Error));
    });
  });

  describe("real-world scenario tests", () => {

    it("handles the actual report user form structure", () => {
      const blockCheckbox = document.getElementById("report_block");
      const blockAndHideLabel = document.getElementById("block_and_hide");
      const submitButton = document.querySelector("button[type=submit] span");

      // Initial state
      expect(submitButton.textContent).toBe("Report");
      expect(blockAndHideLabel.classList.contains("invisible")).toBe(true);

      // Check block checkbox
      blockCheckbox.checked = true;
      blockCheckbox.dispatchEvent(new Event("change"));

      expect(submitButton.textContent).toBe("Block this participant");
      expect(blockAndHideLabel.classList.contains("invisible")).toBe(false);

      // Uncheck block checkbox
      blockCheckbox.checked = false;
      blockCheckbox.dispatchEvent(new Event("change"));

      expect(submitButton.textContent).toBe("Report");
      expect(blockAndHideLabel.classList.contains("invisible")).toBe(true);
    });

    it("works with the radio button form structure (does not interfere)", () => {
      const spamRadio = document.getElementById("spam-flagUserModal");
      const offensiveRadio = document.getElementById("offensive-flagUserModal");
      const submitButton = document.querySelector("button[type=submit] span");

      // Radio buttons should not affect submit button label
      expect(submitButton.textContent).toBe("Report");

      // Select different radio button
      offensiveRadio.checked = true;
      spamRadio.checked = false;
      offensiveRadio.dispatchEvent(new Event("change"));

      // Submit button should remain unchanged
      expect(submitButton.textContent).toBe("Report");
    });

    it("works with the nested label and checkbox structure", () => {
      const blockAndHideLabel = document.getElementById("block_and_hide");
      const hideCheckbox = document.getElementById("report_hide");

      // Initial state - label is invisible
      expect(blockAndHideLabel.classList.contains("invisible")).toBe(true);

      // The hide checkbox should be inside the invisible label
      expect(blockAndHideLabel.contains(hideCheckbox)).toBe(true);

      // Show the label by checking the block checkbox
      const blockCheckbox = document.getElementById("report_block");
      blockCheckbox.checked = true;
      blockCheckbox.dispatchEvent(new Event("change"));

      expect(blockAndHideLabel.classList.contains("invisible")).toBe(false);
    });

    it("handles the complex button structure with SVG icon", () => {
      const submitButton = document.querySelector("button[type=submit]");
      const submitSpan = submitButton.querySelector("span");
      const submitSvg = submitButton.querySelector("svg");

      // Verify structure
      expect(submitSpan).not.toBeNull();
      expect(submitSvg).not.toBeNull();
      expect(submitSpan.textContent).toBe("Report");

      // Test that our manager finds the correct element to update
      const foundSubmitElement = controller.findSubmitButton(document.querySelector("form"));
      expect(foundSubmitElement).toBe(submitSpan);
    });
  });

  describe("edge cases", () => {

    it("handles form without block and hide element", () => {
      // Remove block and hide element
      const blockAndHideElement = document.getElementById("block_and_hide");
      blockAndHideElement.remove();

      const blockCheckbox = document.getElementById("report_block");

      // Should not throw error
      expect(() => {
        blockCheckbox.checked = true;
        blockCheckbox.dispatchEvent(new Event("change"));
      }).not.toThrow();
    });

    it("handles block checkbox without form", () => {
      const isolatedCheckbox = document.createElement("input");
      isolatedCheckbox.type = "checkbox";
      isolatedCheckbox.dataset.block = "true";
      document.body.appendChild(isolatedCheckbox);

      // Should not throw error
      expect(() => {
        controller.toggleBlockAndHideVisibility(isolatedCheckbox);
      }).not.toThrow();
    });

    it("works with different CSS button classes", () => {
      // The actual form uses multiple CSS classes on the button
      const submitButton = document.querySelector("button[type=submit]");
      expect(submitButton.classList.contains("button")).toBe(true);
      expect(submitButton.classList.contains("button__lg")).toBe(true);
      expect(submitButton.classList.contains("button__secondary")).toBe(true);

      // Manager should still find and work with this button
      const foundSubmitElement = controller.findSubmitButton(document.querySelector("form"));
      expect(foundSubmitElement.tagName).toBe("SPAN");
    });
  });
});
