/* eslint max-lines: ["error", 350] */
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
export default class ClipboardCopy {

  /**
   * Timeout duration (in milliseconds) for how long the success message is displayed
   * @type {number}
   */
  static get CLIPBOARD_COPY_TIMEOUT() {
    return 5000;
  }

  /**
   * Constructor - Initialize the clipboard copy functionality
   * @param {HTMLElement} element - The button element that triggers the copy action
   * @throws {Error} If no element is provided
   */
  constructor(element) {
    // Validate that we have a valid DOM element
    if (!element) {
      throw new Error("ClipboardCopy requires a DOM element");
    }

    // Store references to the main elements and configuration
    this.element = element;
    this.targetSelector = element.dataset.clipboardCopy;
    this.customContent = element.dataset.clipboardContent;
    this.copyLabel = element.dataset.clipboardCopyLabel;
    this.copyMessage = element.dataset.clipboardCopyMessage;

    // Initialize state management properties
    // Stores the original button text for restoration
    this.originalLabel = null;
    // Timeout ID for resetting the button text
    this.labelTimeout = null;
    // Screen reader announcement element
    this.messageElement = null;

    // Set up event listeners for this instance
    this._bindEvents();
  }

  /**
   * Bind click event listener to the trigger element
   * @returns {void}
   * @private
   */
  _bindEvents() {
    // Use arrow function to maintain 'this' context
    this.element.addEventListener("click", this._handleClick.bind(this));
  }

  /**
   * Handle click events on the copy button
   * @param {Event} event - The click event object
   * @returns {void}
   * @private
   */
  _handleClick(event) {
    // Prevent any default button behavior (form submission, navigation, etc.)
    event.preventDefault();

    // Early return if no target selector is configured
    if (!this.targetSelector || this.targetSelector.length < 1) {
      return;
    }

    // Find the target element in the DOM
    const targetElement = document.querySelector(this.targetSelector);
    if (!targetElement) {
      // Target element doesn't exist, cannot proceed
      return;
    }

    // Extract the text that should be copied to clipboard
    const textToCopy = this._getTextToCopy(targetElement);
    if (!textToCopy || textToCopy.length < 1) {
      // No text to copy, exit gracefully
      return;
    }

    // Attempt to copy the text to clipboard
    const success = this._copyToClipboard(textToCopy);
    if (success) {
      // Only show feedback if copy operation succeeded
      this._showSuccessMessage(targetElement);
      this._announceToScreenReader();
    }
  }

  /**
   * Determine what text should be copied to the clipboard
   * @param {HTMLElement} targetElement - The element containing the text to copy
   * @returns {string} The text to be copied
   * @private
   */
  _getTextToCopy(targetElement) {
    // Start with custom content if provided via data attribute
    let selectedText = this.customContent || "";

    // If no custom content and target is a form input, use the select library
    // to get the selected/input text
    if (selectedText === "" && this._isInputElement(targetElement)) {
      selectedText = select(targetElement);
    }

    return selectedText;
  }

  /**
   * Check if an element is a form input element (input, textarea, select)
   * @param {HTMLElement} element - The element to check
   * @returns {boolean} True if element is a form input
   * @private
   */
  _isInputElement(element) {
    const inputTags = ["input", "textarea", "select"];
    return inputTags.includes(element.tagName.toLowerCase());
  }

  /**
   * Copy text to the clipboard using the legacy execCommand method
   * Note: Uses execCommand for IE compatibility, though it's deprecated
   * @param {string} text - The text to copy to clipboard
   * @returns {boolean} True if copy operation succeeded
   * @private
   */
  _copyToClipboard(text) {
    // Create a temporary textarea element for the copy operation
    const tempTextarea = document.createElement("textarea");
    tempTextarea.value = text;

    // Position the textarea off-screen so it's not visible to users
    tempTextarea.style.cssText = "width: 1px; height: 1px; position: absolute; left: -9999px;";

    // Insert the temporary element into the DOM
    this.element.parentNode.insertBefore(tempTextarea, this.element.nextSibling);

    // Select the text in the temporary textarea
    tempTextarea.select();

    let success = false;
    try {
      // Use deprecated execCommand for IE compatibility
      // Modern browsers support the Clipboard API, but IE doesn't
      success = document.execCommand("copy");
    } catch (err) {
      // Copy operation failed, set success to false
      success = false;
    }

    // Clean up: remove temporary element and restore focus
    tempTextarea.remove();
    this.element.focus();

    return success;
  }

  /**
   * Display a success message by temporarily changing the button text
   * @param {HTMLElement} targetElement - The target element (used for message placement)
   * @returns {void}
   * @private
   */
  _showSuccessMessage(targetElement) {
    // Exit early if no success label is configured
    if (!this.copyLabel) {
      return;
    }

    // Determine where to show the message (button or target element)
    const messageElement = this._getMessageElement(targetElement);

    // Clear any existing timeout to prevent conflicts
    if (this.labelTimeout) {
      clearTimeout(this.labelTimeout);
    }

    // Store the original text only if we haven't already
    if (!this.originalLabel) {
      this.originalLabel = messageElement.innerHTML;
    }

    // Replace the element content with success message
    messageElement.innerHTML = this.copyLabel;

    // Set up automatic restoration of original text after timeout
    this.labelTimeout = setTimeout(() => {
      messageElement.innerHTML = this.originalLabel;
      // Reset state variables
      this.originalLabel = null;
      this.labelTimeout = null;
    }, ClipboardCopy.CLIPBOARD_COPY_TIMEOUT);
  }

  /**
   * Determine which element should display the success message
   * @param {HTMLElement} targetElement - The target element containing copied text
   * @returns {HTMLElement} The element where success message should be shown
   * @private
   */
  _getMessageElement(targetElement) {
    // If the button has no visible text content (e.g., icon-only button),
    // show the message in the target element instead
    if (this.element.textContent.trim() === "") {
      return targetElement;
    }
    // Otherwise, show the message in the button itself
    return this.element;
  }

  /**
   * Create an announcement for screen readers about the successful copy operation
   * This is crucial for accessibility as screen readers cannot detect clipboard changes
   * @returns {void}
   * @private
   */
  _announceToScreenReader() {
    // Exit early if no message is configured
    if (!this.copyMessage) {
      return;
    }

    // Create the screen reader announcement element if it doesn't exist
    if (!this.messageElement) {
      this.messageElement = document.createElement("div");

      // Configure ARIA attributes for proper screen reader announcement
      this.messageElement.setAttribute("role", "alert");
      this.messageElement.setAttribute("aria-live", "assertive");
      this.messageElement.setAttribute("aria-atomic", "true");

      // Hide from visual display but keep accessible to screen readers
      this.messageElement.className = "sr-only";

      // Append to the button element
      this.element.appendChild(this.messageElement);
    }

    // Prepare the message, adding non-breaking space if same message
    // This forces screen readers to re-announce even if content is identical
    let message = this.copyMessage;
    if (this.messageElement.innerHTML === message) {
      message += "&nbsp;";
    }

    // Update the element content to trigger screen reader announcement
    this.messageElement.innerHTML = message;
  }

  /**
   * Clean up the instance by clearing timeouts and removing DOM elements
   * Call this method when the instance is no longer needed
   * @returns {void}
   */
  destroy() {
    // Clear any pending timeout
    if (this.labelTimeout) {
      clearTimeout(this.labelTimeout);
    }

    // Remove screen reader message element if it exists
    if (this.messageElement) {
      this.messageElement.remove();
    }

    // Remove event listener to prevent memory leaks
    this.element.removeEventListener("click", this._handleClick);
  }

  /**
   * Static method to initialize clipboard copy functionality for all elements
   * with the data-clipboard-copy attribute on the page
   * This prevents duplicate initialization by checking for existing instances
   * @returns {void}
   */
  static initializeAll() {
    // Find all elements with the clipboard copy data attribute
    document.querySelectorAll("[data-clipboard-copy]").forEach((element) => {
      // Only initialize if not already initialized (prevents duplicates)
      if (!element._clipboardCopy) {
        element._clipboardCopy = new ClipboardCopy(element);
      }
    });
  }
}
