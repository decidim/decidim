import { Controller } from "@hotwired/stimulus"

/**
 * Toggles the visibility of the access mode options according to the
 * "This space has members" checkbox.
 *
 * The controller expects to sit on the access accordion so it can
 * query the checkbox and the `#access_mode` fieldset that lives inside.
 */
export default class extends Controller {

  /**
   * Find the relevant inputs and attach the change listener.
   * @returns {void}
   */
  connect() {
    this.hasMembersCheckbox = this.element.querySelector("#has_members input[type='checkbox']")
    this.accessModeFieldset = this.element.querySelector("#access_mode")

    if (!this.hasMembersCheckbox || !this.accessModeFieldset) {
      return
    }

    this.toggleAccessMode = this.toggleAccessMode.bind(this)
    this.hasMembersCheckbox.addEventListener("change", this.toggleAccessMode)
    this.toggleAccessMode()
  }

  /**
   * Remove the listener bound during `connect`.
   * @returns {void}
   */
  disconnect() {
    if (this.hasMembersCheckbox && this.toggleAccessMode) {
      this.hasMembersCheckbox.removeEventListener("change", this.toggleAccessMode)
    }
  }

  /**
   * Show or hide the access mode fieldset depending on the checkbox state.
   * @returns {void}
   */
  toggleAccessMode() {
    const showAccessMode = this.hasMembersCheckbox.checked

    this.accessModeFieldset.disabled = !showAccessMode
    this.accessModeFieldset.hidden = !showAccessMode
    this.accessModeFieldset.style.display = showAccessMode
      ? ""
      : "none"
  }
}
