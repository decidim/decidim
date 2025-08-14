/**
 * Handles standard user registration form functionality.
 * Extends BaseRegistrationForm with standard registration specific behavior.
 */
class UserRegistrationForm {

  /**
   * Creates a new BaseRegistrationForm instance
   * @param {HTMLElement} formElement - The form element to manage
   * @param {String} modalSelector - The newsletter modal selector element
   */
  constructor(formElement, modalSelector = "sign-up-newsletter-modal") {
    this.formElement =  document.getElementById(formElement);
    this.modal = document.getElementById(modalSelector);
    this.newsletterSelector = 'input[type="checkbox"][name="user[newsletter]"]';
    this.isInitialized = false;
  }

  /**
   * Initializes the form by setting up event listeners
   * @returns {void}
   */
  initialize() {
    if (this.isInitialized || !this.exists()) {
      return;
    }

    this.setupFormEventListeners();
    this.setupModalEventListeners();
    this.isInitialized = true;
  }

  /**
   * Sets up form submission event listener
   * @private
   * @returns {void}
   */
  setupFormEventListeners() {
    if (this.exists()) {
      this.formElement.addEventListener("submit", (event) => {
        this.handleFormSubmission(event);
      });
    }
  }

  /**
   * Sets up event listeners for modal button interactions
   * @private
   * @returns {void}
   */
  setupModalEventListeners() {
    if (!this.modal || this.modal.dataset.listenersAttached) {
      return;
    }

    const modalButtons = this.modal.querySelectorAll("[data-check]");
    modalButtons.forEach((button) => {
      button.addEventListener("click", (event) => {
        const shouldCheck = event.target.dataset.check === "true";
        this.processNewsletterSelection(shouldCheck);
      });
    });

    // Mark that listeners are attached to prevent duplicate listeners
    this.modal.dataset.listenersAttached = "true";
  }

  /**
   * Handles form submission and prevents it if newsletter modal should be shown
   * @param {Event} event - The form submission event
   * @private
   * @returns {void}
   */
  handleFormSubmission(event) {
    const modalContinueFlag = this.getModalContinueFlag();

    if (!modalContinueFlag) {
      if (!this.isNewsletterChecked()) {
        event.preventDefault();
        this.openModal();
      }
    }
  }

  /**
   * Processes the newsletter selection from the modal and submits all forms
   * @param {boolean} shouldCheck - Whether to check the newsletter checkbox
   * @private
   * @returns {void}
   */
  processNewsletterSelection(shouldCheck) {
    this.setNewsletterCheckbox(shouldCheck);
    this.setModalContinueFlag(true);
    this.closeModal();
    this.submit();
  }

  /**
   * Gets the newsletter checkbox element from the form
   * @returns {HTMLElement|null} The newsletter checkbox element
   */
  getNewsletterCheckbox() {
    return this.formElement.querySelector(this.newsletterSelector);
  }

  /**
   * Checks if the newsletter checkbox is checked
   * @returns {boolean} Whether the newsletter checkbox is checked
   */
  isNewsletterChecked() {
    const checkbox = this.getNewsletterCheckbox();

    return checkbox
      ? checkbox.checked
      : false;
  }

  /**
   * Sets the newsletter checkbox state
   * @param {boolean} checked - Whether to check the checkbox
   * @returns {void}
   */
  setNewsletterCheckbox(checked) {
    const checkbox = this.getNewsletterCheckbox();
    if (checkbox) {
      checkbox.checked = checked;
    }
  }

  /**
   * Submits the form programmatically
   * @returns {void}
   */
  submit() {
    if (this.exists()) {
      this.formElement.requestSubmit();
    }
  }

  /**
   * Gets the modal continue flag from the modal data attributes
   * @returns {boolean} Whether the modal has been continued
   * @private
   */
  getModalContinueFlag() {
    if (!this.modal) {
      return false;
    }
    return this.modal.dataset.continue === "true";
  }

  /**
   * Sets the modal continue flag in the modal data attributes
   * @param {boolean} value - The continue flag value
   * @private
   * @returns {void}
   */
  setModalContinueFlag(value) {
    if (this.modal) {
      this.modal.dataset.continue = value.toString();
    }
  }

  /**
   * Opens the newsletter modal using the Decidim dialog system
   * @private
   * @returns {void}
   */
  openModal() {
    if (window.Decidim?.currentDialogs?.["sign-up-newsletter-modal"]) {
      window.Decidim.currentDialogs["sign-up-newsletter-modal"].open();
    }
  }

  /**
   * Closes the newsletter modal using the Decidim dialog system
   * @private
   * @returns {void}
   */
  closeModal() {
    if (window.Decidim?.currentDialogs?.["sign-up-newsletter-modal"]) {
      window.Decidim.currentDialogs["sign-up-newsletter-modal"].close();
    }
  }

  /**
   * Checks if the form exists and is valid
   * @returns {boolean} Whether the form exists
   */
  exists() {
    return this.formElement !== null;
  }

}

export default UserRegistrationForm;
