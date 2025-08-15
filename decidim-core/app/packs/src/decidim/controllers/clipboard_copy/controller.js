/* eslint max-lines: ["error", 450] */
import { Controller } from "@hotwired/stimulus"
import select from "select";

/**
 * ClipboardCopy - A class that provides clipboard copy functionality for buttons.
 *
 * This class eliminates jQuery dependencies and provides a clean, standalone
 * implementation for copying text to the clipboard with visual feedback and
 * accessibility features.
 *
 * Usage:
 *   1. Create a button with data attributes:
 *     <button class="button"
 *      data-controller="clipboard-copy"
 *      data-clipboard-copy="#target-input-element"
 *      data-clipboard-copy-label="Copied!"
 *      data-clipboard-copy-message="The text was successfully copied to clipboard."
 *      aria-label="Copy the text to clipboard">
 *        Copy to clipboard
 *    </button>
 *
 *   2. Ensure the target element exists:
 *     <input id="target-input-element" type="text" value="This text will be copied.">
 *
 * Data attributes:
 * - data-clipboard-copy: CSS selector for the target element containing text to copy
 * - data-clipboard-content: Optional custom text to copy (overrides target element content)
 * - data-clipboard-copy-label: Text to display in button after successful copy
 * - data-clipboard-copy-message: Message announced to screen readers after copy
 */
export default class extends Controller {

  /**
   * Initialize the clipboard copy controller and set up initial state.
   *
   * This method is automatically called by Stimulus when the controller is connected
   * to the DOM. It extracts configuration from data attributes, initializes state
   * management properties, and binds event listeners.
   *
   * Sets up the following properties from data attributes:
   * - targetSelector: CSS selector for the element containing text to copy
   * - customContent: Optional custom text content to copy instead of target element
   * - copyLabel: Text to temporarily display after successful copy
   * - copyMessage: Accessibility message for screen readers
   *
   * Initializes state tracking properties:
   * - originalLabel: Stores the original button text for restoration
   * - labelTimeout: Manages the timeout for restoring original button text
   * - messageElement: DOM element for screen reader announcements
   *
   * @returns {void}
   * @public
   */
  connect() {
    this.targetSelector = this.element.dataset.clipboardCopy;
    this.customContent = this.element.dataset.clipboardContent;
    this.copyLabel = this.element.dataset.clipboardCopyLabel;
    this.copyMessage = this.element.dataset.clipboardCopyMessage;

    this.originalLabel = null;
    this.labelTimeout = null;
    this.messageElement = null;

    this.bindEvents();
  }

  /**
   * Clean up resources and remove event listeners when controller is disconnected.
   *
   * This method is automatically called by Stimulus when the controller is
   * disconnected from the DOM. It performs cleanup operations to prevent
   * memory leaks and ensures proper resource management.
   *
   * Cleanup operations include:
   * - Clearing any pending timeout for label restoration
   * - Removing screen reader announcement elements from DOM
   * - Removing click event listener from the trigger element
   *
   * This method should be called automatically by Stimulus lifecycle, but can
   * be called manually if needed for cleanup in special cases.
   *
   * @returns {void}
   * @public
   */
  disconnect() {
    // Clear any pending timeout
    if (this.labelTimeout) {
      clearTimeout(this.labelTimeout);
    }

    if (this.messageElement) {
      this.messageElement.remove();
    }

    this.element.removeEventListener("click", this.handleClick);
  }

  /**
   * Bind click event listener to the controller element.
   *
   * This method attaches a click event listener to the controller's DOM element
   * (typically a button). The listener is bound with proper context to ensure
   * 'this' refers to the controller instance within the event handler.
   *
   * The bound event handler will trigger the clipboard copy functionality
   * when the user clicks the element.
   *
   * @returns {void}
   * @private
   */
  bindEvents() {
    this.element.addEventListener("click", this.handleClick.bind(this));
  }

  /**
   * Handle click events on the copy button and orchestrate the copy operation.
   *
   * This method serves as the main entry point for clipboard copy functionality.
   * It coordinates the entire copy process from validation to user feedback.
   *
   * Process flow:
   * 1. Prevents default click behavior to avoid form submissions or navigation
   * 2. Validates that a target selector is configured
   * 3. Locates the target element in the DOM using the CSS selector
   * 4. Extracts or determines the text content to be copied
   * 5. Performs the actual clipboard copy operation
   * 6. Provides visual and accessibility feedback on success
   *
   * Early returns occur if:
   * - No target selector is configured
   * - Target element cannot be found in DOM
   * - No text content is available to copy
   *
   * @param {Event} event - The DOM click event object containing event details
   * @returns {void}
   * @private
   */
  handleClick(event) {
    event.preventDefault();

    if (!this.targetSelector || this.targetSelector.length < 1) {
      return;
    }

    const targetElement = document.querySelector(this.targetSelector);
    if (!targetElement) {
      return;
    }

    const textToCopy = this.getTextToCopy(targetElement);
    if (!textToCopy || textToCopy.length < 1) {
      return;
    }

    const success = this.copyToClipboard(textToCopy);
    if (success) {
      this.showSuccessMessage(targetElement);
      this.announceToScreenReader();
    }
  }

  /**
   * Determine what text content should be copied to the clipboard.
   *
   * This method implements a priority system for determining copy content:
   * 1. Custom content from data-clipboard-content attribute (highest priority)
   * 2. Selected text from form input elements using the select library
   *
   * For form input elements (input, textarea, select), this method uses
   * the 'select' library to properly select and extract the element's content.
   * This approach handles different input types and ensures proper text selection.
   *
   * @param {HTMLElement} targetElement - The DOM element containing text to copy
   * @returns {string} The text content to be copied to clipboard, empty string if none found
   * @private
   */
  getTextToCopy(targetElement) {
    let selectedText = this.customContent || "";

    if (selectedText === "" && this.isInputElement(targetElement)) {
      selectedText = select(targetElement);
    }

    return selectedText;
  }

  /**
   * Check if a DOM element is a form input element.
   *
   * This method determines whether the given element is one of the standard
   * HTML form input elements that can contain user-editable text content.
   * This check is used to determine the appropriate method for text extraction.
   *
   * Recognized input elements:
   * - input: Text inputs, password fields, email fields, etc.
   * - textarea: Multi-line text input areas
   * - select: Dropdown selection elements
   *
   * The comparison is case-insensitive to handle potential variations in
   * element tag casing.
   *
   * @param {HTMLElement} element - The DOM element to examine
   * @returns {boolean} True if the element is a form input element, false otherwise
   * @private
   */
  isInputElement(element) {
    const inputTags = ["input", "textarea", "select"];
    return inputTags.includes(element.tagName.toLowerCase());
  }

  /**
   * Copy text to the system clipboard using the deprecated execCommand method.
   *
   * This method implements clipboard copying using the legacy document.execCommand
   * approach for maximum browser compatibility, including older versions of
   * Internet Explorer that does not support the modern Clipboard API.
   *
   * Implementation details:
   * 1. Creates a temporary invisible textarea element
   * 2. Sets the textarea content to the text to be copied
   * 3. Positions textarea off-screen to hide it from users
   * 4. Inserts textarea into DOM adjacent to the trigger element
   * 5. Selects all text within the temporary textarea
   * 6. Executes the copy command using deprecated execCommand
   * 7. Removes temporary element and restores focus
   *
   * The textarea is positioned at coordinates (-9999px) to ensure it is
   * completely off-screen while remaining part of the document flow
   * for proper text selection.
   *
   * Note: This method uses the deprecated execCommand API for IE compatibility.
   * Modern applications should consider migrating to the Clipboard API when
   * legacy browser support is no longer required.
   *
   * @param {string} text - The text content to copy to the system clipboard
   * @returns {boolean} True if the copy operation succeeded, false if it failed
   * @private
   */
  copyToClipboard(text) {
    //
    const tempTextarea = document.createElement("textarea");
    tempTextarea.value = text;

    tempTextarea.style.cssText = "width: 1px; height: 1px; position: absolute; left: -9999px;";
    this.element.parentNode.insertBefore(tempTextarea, this.element.nextSibling);

    tempTextarea.select();

    let success = false;
    try {
      // Use deprecated execCommand for IE compatibility
      // Modern browsers support the Clipboard API, but IE does not
      success = document.execCommand("copy");
    } catch (err) {
      success = false;
    }

    tempTextarea.remove();
    this.element.focus();

    return success;
  }

  /**
   * Display visual feedback by temporarily changing the button or target element text.
   *
   * This method provides immediate visual confirmation to users that the copy
   * operation completed successfully. It temporarily replaces the element's
   * content with a success message, then restores the original content after
   * a predefined timeout period.
   *
   * Behavior:
   * 1. Determines the appropriate element to show the message on
   * 2. Stores the original content for later restoration
   * 3. Displays the success message from copyLabel configuration
   * 4. Sets a 5-second timeout to restore the original content
   * 5. Manages timeout cleanup to prevent overlapping operations
   *
   * The method handles multiple rapid clicks by clearing any existing
   * timeout before setting a new one, ensuring the message display
   * duration is always 5 seconds from the most recent successful copy.
   *
   * Early return occurs if no copyLabel is configured, allowing the
   * component to work without visual feedback if desired.
   *
   * @param {HTMLElement} targetElement - The target element containing copied text,
   *                                      used for determining message placement
   * @returns {void}
   * @private
   */
  showSuccessMessage(targetElement) {
    if (!this.copyLabel) {
      return;
    }

    const messageElement = this.getMessageElement(targetElement);

    if (this.labelTimeout) {
      clearTimeout(this.labelTimeout);
    }

    if (!this.originalLabel) {
      this.originalLabel = messageElement.innerHTML;
    }

    messageElement.innerHTML = this.copyLabel;

    this.labelTimeout = setTimeout(() => {
      messageElement.innerHTML = this.originalLabel;
      this.originalLabel = null;
      this.labelTimeout = null;
    }, 5000);
  }

  /**
   * Determine which DOM element should display the visual success message.
   *
   * This method implements a simple heuristic to choose the most appropriate
   * element for displaying the temporary success message based on the
   * controller element's content state.
   *
   * Decision logic:
   * - If the trigger element (button) has no visible text content, the success
   *   message is shown on the target element (the element containing copied text)
   * - If the trigger element has text content, the message is shown on the
   *   trigger element itself (typically the button)
   *
   * This approach ensures that users always see visual feedback in a logical
   * location, whether they are using a text button or an icon-only button.
   *
   * @param {HTMLElement} targetElement - The target element containing the copied text
   * @returns {HTMLElement} The DOM element where the success message should be displayed
   * @private
   */
  getMessageElement(targetElement) {
    if (this.element.textContent.trim() === "") {
      return targetElement;
    }
    return this.element;
  }

  /**
   * Create and manage screen reader announcements for accessibility compliance.
   *
   * This method ensures that users of assistive technologies (screen readers)
   * receive notification when clipboard copy operations complete successfully.
   * Since screen readers cannot detect clipboard changes directly, this method
   * creates ARIA live regions to announce the success.
   *
   * Implementation details:
   * 1. Creates a screen reader announcement element if it does not exist
   * 2. Configures ARIA attributes for optimal screen reader support:
   *    - aria-role="alert": Indicates important, time-sensitive information
   *    - aria-live="assertive": Ensures immediate announcement, interrupting other content
   *    - aria-atomic="true": Announces the entire message as a unit
   * 3. Applies "sr-only" CSS class to hide the element visually while keeping it
   *    accessible to screen readers
   * 4. Handles edge cases where the message element might be removed from DOM
   * 5. Prevents duplicate announcements by appending non-breaking space when needed
   *
   * The method includes DOM validation and automatic recovery if the message
   * element is unexpectedly removed from the document, ensuring reliable
   * accessibility feedback.
   *
   * Early return occurs if no copyMessage is configured, making accessibility
   * announcements optional while maintaining functionality.
   *
   * @returns {void}
   * @private
   */
  announceToScreenReader() {
    if (!this.copyMessage) {
      return;
    }

    if (!this.messageElement) {
      this.messageElement = document.createElement("div");

      this.messageElement.setAttribute("aria-role", "alert");
      this.messageElement.setAttribute("aria-live", "assertive");
      this.messageElement.setAttribute("aria-atomic", "true");

      this.messageElement.className = "sr-only";

      this.element.appendChild(this.messageElement);
    }

    if (!document.body.contains(this.messageElement)) {
      console.warn("Message element was removed from DOM, recreating...");
      this.messageElement = null;
      this.announceToScreenReader();
      return;
    }

    let message = this.copyMessage;
    if (this.messageElement.innerHTML === message) {
      message += "&nbsp;";
    }

    this.messageElement.innerHTML = message;
  }
}
