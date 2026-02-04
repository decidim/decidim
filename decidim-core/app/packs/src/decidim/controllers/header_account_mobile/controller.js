import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller that activates the mobile account dropdown by setting
 * `aria-modal="true"` on the target element when the trigger is clicked.
 *
 * Expected markup:
 * - The controller element has a `data-target` attribute with the dropdown id.
 */
export default class extends Controller {
  connect() {
    this.dropdownMobileDiv = document.getElementById(this.element.dataset.target);

    this.handleClick = this.handleClick.bind(this);
    this.element.addEventListener("click", this.handleClick);
  }

  disconnect() {
    this.element.removeEventListener("click", this.handleClick)
  }

  handleClick() {
    if (!this.dropdownMobileDiv) {
      return;
    }
    this.dropdownMobileDiv.setAttribute("aria-modal", "true")
  }

}
