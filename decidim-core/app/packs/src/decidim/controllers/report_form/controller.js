import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    this.options = {
      hideSelector: '[data-hide="true"]',
      blockSelector: '[data-block="true"]',
      blockAndHideSelector: "#block_and_hide",
      submitSelector: 'button[type="submit"]'
    };

    this.isInitialized = false;
    this.eventListeners = new Map();
  }

  /**
   * Creates a new ReportFormManager instance
   *
   * @param {HTMLElement} container - The form container element that handles the report
   * @param {Object} options - Configuration options for the manager
   * @param {string} options.hideSelector - CSS selector for hide checkboxes (default: '[data-hide="true"]')
   * @param {string} options.blockSelector - CSS selector for block checkboxes (default: '[data-block="true"]')
   * @param {string} options.blockAndHideSelector - CSS selector for block and hide element (default: '#block_and_hide')
   * @param {string} options.submitSelector - CSS selector for submit button (default: 'button[type="submit"]')
   * @returns {void}
   */
  connect() {
    if (!this.element || this.isInitialized) {
      return;
    }

    try {
      this.setupHideCheckboxes();
      this.setupBlockCheckboxes();
      this.isInitialized = true;
    } catch (error) {
      console.error("Failed to initialize ReportFormManager:", error);
    }
  }

  disconnect() {
    try {
      // Remove all event listeners
      this.eventListeners.forEach((listenerInfo, element) => {
        element.removeEventListener(listenerInfo.event, listenerInfo.handler);
      });

      // Clear the listeners map
      this.eventListeners.clear();

      // Reset initialization state
      this.isInitialized = false;

      // Clear references
      this.container = null;
    } catch (error) {
      console.error("Error during ReportFormManager cleanup:", error);
    }
  }

  /**
   * Sets up event listeners for hide checkboxes
   * These checkboxes change the submit button label between report and hide actions
   *
   * @returns {void}
   */
  setupHideCheckboxes() {
    const hideCheckboxes = this.element.querySelectorAll(this.options.hideSelector);

    hideCheckboxes.forEach((checkbox) => {
      const changeHandler = (event) => {
        this.handleCheckboxChange(event.target);
      };

      checkbox.addEventListener("change", changeHandler);
      this.eventListeners.set(checkbox, { event: "change", handler: changeHandler });
    });
  }

  /**
   * Sets up event listeners for block checkboxes
   * These checkboxes handle user blocking functionality and toggle visibility of additional options
   *
   * @returns {void}
   */
  setupBlockCheckboxes() {
    const blockCheckboxes = this.element.querySelectorAll(this.options.blockSelector);

    blockCheckboxes.forEach((checkbox) => {
      const changeHandler = (event) => {
        this.handleCheckboxChange(event.target);
        this.toggleBlockAndHideVisibility(event.target);
      };

      checkbox.addEventListener("change", changeHandler);
      this.eventListeners.set(checkbox, { event: "change", handler: changeHandler });
    });
  }

  /**
   * Handles checkbox change events by updating the submit button label
   *
   * @param {HTMLInputElement} checkbox - The checkbox element that triggered the change
   * @returns {void}
   */
  handleCheckboxChange(checkbox) {
    try {
      const form = checkbox.closest("form");
      if (!form) {
        console.warn("Checkbox is not within a form element");
        return;
      }

      const submitButton = this.findSubmitButton(form);
      if (!submitButton) {
        console.warn("No submit button found in form");
        return;
      }

      this.updateSubmitButtonLabel(submitButton, checkbox);
    } catch (error) {
      console.error("Error handling checkbox change:", error);
    }
  }

  /**
   * Finds the submit button within a form, checking for nested span elements
   *
   * @param {HTMLFormElement} form - The form element to search within
   * @returns {HTMLElement|null} The submit button element or its nested span, or null if not found
   */
  findSubmitButton(form) {
    const submitButton = form.querySelector(this.options.submitSelector);
    if (!submitButton) {
      return null;
    }

    // Check if the button has a nested span element for the text
    const nestedSpan = submitButton.querySelector("span");
    return nestedSpan || submitButton;
  }

  /**
   * Updates the submit button label based on checkbox state and data attributes
   *
   * @param {HTMLElement} submitElement - The submit button or its text container element
   * @param {HTMLInputElement} checkbox - The checkbox that triggered the update
   * @returns {void}
   */
  updateSubmitButtonLabel(submitElement, checkbox) {
    if (!checkbox.dataset.labelAction || !checkbox.dataset.labelReport) {
      console.warn("Checkbox is missing required data attributes (data-label-action, data-label-report)");
      return;
    }

    const newLabel = checkbox.checked
      ? checkbox.dataset.labelAction
      : checkbox.dataset.labelReport;

    submitElement.innerHTML = newLabel;
  }

  /**
   * Toggles the visibility of the block and hide element when block checkboxes are changed
   *
   * @param {HTMLInputElement} blockCheckbox - The block checkbox that was changed
   * @returns {void}
   */
  toggleBlockAndHideVisibility(blockCheckbox) {
    try {
      const form = blockCheckbox.closest("form");
      if (!form) {
        return;
      }

      const blockAndHideElement = form.querySelector(this.options.blockAndHideSelector);
      if (blockAndHideElement) {
        blockAndHideElement.classList.toggle("invisible");
      }
    } catch (error) {
      console.error("Error toggling block and hide visibility:", error);
    }
  }
}
