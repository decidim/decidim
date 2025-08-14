import { Controller } from "@hotwired/stimulus"
import icon from "src/decidim/icon"

/**
 * PasswordToggler Stimulus Controller
 *
 * A Stimulus controller that adds password visibility toggle functionality to password input fields.
 * This controller creates a button that allows users to show/hide their password text for better
 * user experience while maintaining security.
 *
 * Features:
 * - Adds a toggle button with eye/eye-off icons
 * - Provides screen reader support with ARIA labels and live regions
 * - Automatically hides password on form submission for security
 * - Handles form error positioning correctly
 * - Supports customizable text labels via data attributes
 *
 * Required HTML structure:
 * - Container element with this controller
 * - Password input field inside the container
 *
 * Optional data attributes:
 * - data-show-password: Custom text for "show password" button
 * - data-hide-password: Custom text for "hide password" button
 * - data-hidden-password: Custom text for screen readers when password is hidden
 * - data-shown-password: Custom text for screen readers when password is shown
 *
 * @extends Controller
 */
export default class extends Controller {

  /**
   * Initializes the password toggler when the controller connects to the DOM.
   * Sets up the password input reference, form reference, text labels, icons,
   * and initializes all toggle functionality.
   * @returns {void}
   */
  connect() {
    this.input = this.element.querySelector('input[type="password"]');

    if (!this.input) {
      console.warn("PasswordToggler requires a password input element");
      return;
    }

    this.form = this.input.closest("form");
    this.texts = {
      showPassword: this.element.getAttribute("data-show-password") || "Show password",
      hidePassword: this.element.getAttribute("data-hide-password") || "Hide password",
      hiddenPassword: this.element.getAttribute("data-hidden-password") || "Your password is hidden",
      shownPassword: this.element.getAttribute("data-shown-password") || "Your password is shown"
    }
    this.icons = {
      show: icon("eye-line"),
      hide: icon("eye-off-line")
    }

    this.init();
  }

  /**
   * Cleanup method called when the controller disconnects from the DOM.
   * Removes event listeners to prevent memory leaks.
   * @returns {void}
   */
  disconnect() {
    if (this.button && this.boundToggleVisibility) {
      this.button.removeEventListener("click", this.boundToggleVisibility);
    }
    if (this.form && this.boundHidePassword) {
      this.form.removeEventListener("submit", this.boundHidePassword);
    }
  }


  /**
   * Initializes the password toggle functionality.
   * Creates the UI controls, binds event listeners, and sets up form submission handling.
   * This method is called after the controller connects to ensure proper setup.
   * @returns {void}
   */
  init() {
    this.createControls();

    // Bind methods to maintain correct context
    this.boundToggleVisibility = this.toggleVisibility.bind(this);
    this.boundHidePassword = this.hidePassword.bind(this);

    this.button.addEventListener("click", this.boundToggleVisibility);

    if (this.form) {
      this.form.addEventListener("submit", this.boundHidePassword);
    }
  }

  /**
   * Creates all UI controls needed for the password toggle functionality.
   * This includes the toggle button, status text for screen readers, and
   * the input group wrapper structure.
   * @returns {void}
   */
  createControls() {
    this.createButton();
    this.createStatusText();
    this.addInputGroupWrapperAsParent();
  }

  /**
   * Creates the toggle button element with appropriate ARIA attributes.
   * The button shows an eye icon initially and is configured for accessibility
   * with proper labels and controls relationships.
   * @returns {void}
   */
  createButton() {
    const button = document.createElement("button");
    button.setAttribute("type", "button");
    button.setAttribute("aria-controls", this.input.getAttribute("id"));
    button.setAttribute("aria-label", this.texts.showPassword);
    button.innerHTML = this.icons.show;
    this.button = button;
  }

  /**
   * Creates a screen reader status text element.
   * This invisible element announces password visibility changes to users
   * using assistive technologies via the aria-live attribute.
   * @returns {void}
   */
  createStatusText() {
    const statusText = document.createElement("span");
    statusText.classList.add("sr-only");
    statusText.setAttribute("aria-live", "polite");
    statusText.textContent = this.texts.hiddenPassword;
    this.statusText = statusText;
  }

  /**
   * Wraps the password input in a styled container and positions all elements.
   * Creates an input group structure that includes the original input, toggle button,
   * status text, and preserves any form error messages in the correct position.
   *
   * The resulting DOM structure:
   * - input-group__password wrapper
   *   - toggle button
   *   - password input
   *   - status text (screen reader only)
   *   - form error (if present)
   * @returns {void}
   */
  addInputGroupWrapperAsParent() {
    if (!this.input.parentNode) {
      console.warn("Password input has no parent node");
      return;
    }

    const inputGroupWrapper = document.createElement("div");
    inputGroupWrapper.classList.add("input-group__password");

    const parent = this.input.parentNode;
    const nextSibling = this.input.nextSibling;

    this.input.remove();

    inputGroupWrapper.appendChild(this.button);
    inputGroupWrapper.appendChild(this.input);
    inputGroupWrapper.appendChild(this.statusText);

    if (nextSibling) {
      parent.insertBefore(inputGroupWrapper, nextSibling);
    } else {
      parent.appendChild(inputGroupWrapper);
    }

    const formError = this.element.querySelector(".form-error");
    if (formError && formError.parentNode !== inputGroupWrapper) {
      inputGroupWrapper.appendChild(formError);
    }
  }

  /**
   * Toggles password visibility when the toggle button is clicked.
   * Prevents the default button behavior and switches between showing
   * and hiding the password based on the current state.
   *
   * @param {Event} evt - The click event from the toggle button
   * @returns {void}
   */
  toggleVisibility(evt) {
    evt.preventDefault();
    if (this.isText()) {
      this.hidePassword();
    } else {
      this.showPassword();
    }
  }

  /**
   * Shows the password as plain text.
   * Updates the input type to "text", changes the button icon to "hide",
   * updates ARIA labels, and announces the change to screen readers.
   * @returns {void}
   */
  showPassword() {
    this.statusText.textContent = this.texts.shownPassword;
    this.button.setAttribute("aria-label", this.texts.hidePassword);
    this.button.innerHTML = this.icons.hide;
    this.input.setAttribute("type", "text");
  }

  /**
   * Hides the password (shows dots/asterisks).
   * Updates the input type to "password", changes the button icon to "show",
   * updates ARIA labels, and announces the change to screen readers.
   * This method is also called automatically on form submission for security.
   * @returns {void}
   */
  hidePassword() {
    this.statusText.textContent = this.texts.hiddenPassword;
    this.button.setAttribute("aria-label", this.texts.showPassword);
    this.button.innerHTML = this.icons.show;
    this.input.setAttribute("type", "password");
  }

  /**
   * Checks if the password is currently visible as plain text.
   *
   * @returns {boolean} True if password is visible (type="text"), false if hidden (type="password")
   */
  isText() {
    return this.input.getAttribute("type") === "text"
  }
}
