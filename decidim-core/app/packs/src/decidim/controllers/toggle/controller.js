import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static get values() {
    return {
      toggle: String
    }
  }

  connect() {
    this.ensureComponentId();
    this.setupAriaControls();
    this.setupAriaLabelledBy();
    this.bindEvents();
  }

  /**
   * Destroy the toggle instance and clean up event listeners
   * @public
   * @returns {void}
   */
  disconnect() {
    this.element.removeEventListener("click", this.handleToggle);
  }

  /**
   * Ensure the component has an ID
   * @private
   * @returns {void}
   */
  ensureComponentId() {
    if (!this.element.id) {
      this.element.id = `toggle-${Math.random().toString(36).substring(7)}`;
    }
  }

  /**
   * Set up aria-controls attribute
   * @private
   * @returns {void}
   */
  setupAriaControls() {
    this.element.setAttribute("aria-controls", this.toggleValue);
  }

  /**
   * Set up aria-labelledby attributes for target elements
   * @private
   * @returns {void}
   */
  setupAriaLabelledBy() {
    this.getTargetIds().forEach((id) => {
      const node = document.getElementById(id);

      if (node) {
        const existingLabel = node.getAttribute("aria-labelledby");
        const newLabel = [existingLabel, this.element.id].
          filter(Boolean).
          join(" ");

        node.setAttribute("aria-labelledby", newLabel);
      }
    });
  }

  /**
   * Bind click event listener
   * @private
   * @returns {void}
   */
  bindEvents() {
    this.element.addEventListener("click", () => this.handleToggle());
  }

  /**
   * Handle the toggle action
   * @private
   * @returns {void}
   */
  handleToggle() {
    this.getTargetIds().forEach((id) => {
      const node = document.getElementById(id);

      if (node) {
        node.hidden = !node.hidden;
        node.setAttribute("aria-expanded", !node.hidden);
      }
    });

    this.dispatchToggleEvent();
  }

  /**
   * Get array of target element IDs
   * @private
   * @returns {string[]} Array of element IDs
   */
  getTargetIds() {
    return this.toggleValue.split(" ");
  }

  /**
   * Dispatch custom toggle event
   * @private
   * @returns {void}
   */
  dispatchToggleEvent() {
    document.dispatchEvent(new Event("on:toggle"));
  }
}
