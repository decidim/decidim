import { Controller } from "@hotwired/stimulus"

/**
 * Controls selective display elements on the page. For example, if you want to
 * display a certain element on the page only when specific value from a select
 * element is chosen.
 *
 * Example:
 *
 *   <select id="triggering_select">
 *     <option value="one">One</option>
 *     <option value="two">Two</option>
 *   </select>
 *
 *   <div class="hide" data-controller="selective-display" data-selective-display-selector-value="#triggering_select" data-selective-display-triggers-value="one">
 *     <p>This is displayed when value "one" is selected</p>
 *   </div>
 *
 *   <div class="hide" data-controller="selective-display" data-selective-display-selector-value="#triggering_select" data-selective-display-triggers-value="two">
 *     <p>This is displayed when value "two" is selected</p>
 *   </div>
 *
 *   <div class="hide" data-controller="selective-display" data-selective-display-selector-value="#triggering_select" data-selective-display-triggers-value="one two">
 *     <p>This is displayed when either value "one" or "two" is selected</p>
 *   </div>
 */
export default class extends Controller {
  static get values() {
    return {
      selector: String,
      triggers: String
    }
  }

  connect() {
    if (!this.selectorValue || !this.triggersValue) {
      return;
    }

    this.triggeringInput = document.querySelector(this.selectorValue);
    if (!this.triggeringInput) {
      return;
    }

    this.triggersList = this.triggersValue.split(" ");
    this._changeListenerProxy = this.onValueChange.bind(this);
    this.triggeringInput.addEventListener("change", this._changeListenerProxy);

    // Trigger initial change to set the initial state of the element.
    this.onValueChange();
  }

  disconnect() {
    if (this.triggeringInput) {
      this.triggeringInput.removeEventListener("change", this._changeListenerProxy)
    }

    Reflect.deleteProperty(this, "triggeringInput");
    Reflect.deleteProperty(this, "triggersList");
    Reflect.deleteProperty(this, "_changeListenerProxy");
  }

  onValueChange() {
    if (this.triggersList.includes(this.triggeringInput.value)) {
      this.element.classList.remove("hide");
    } else {
      this.element.classList.add("hide");
    }
  }
}
