import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller for the global search results filter dropdown.
 *
 * Reproduces the accessible open/close behavior of the resource-type filter:
 * the trigger button holds the `aria-expanded` state and the menu lists its
 * visibility. Two arrow icons inside the button drive the state (the down
 * arrow expands, the up arrow collapses), and keyboard activation on the button
 * (Enter / Space) toggles it. Every state change is intentionally delayed by
 * 300ms to mirror the previous inline implementation.
 *
 * Targets:
 *   - `trigger` – The button that holds the `aria-expanded` attribute.
 *   - `arrowDown` – The down arrow icon; collapsing → expanding.
 *   - `arrowUp` – The up arrow icon; expanding → collapsing.
 *   - `list` – The dropdown menu whose `display` is toggled.
 */
export default class SearchFilterDropdownController extends Controller {

  /**
   * Expands the dropdown after a 300ms delay.
   * Bound to the down arrow click; mirrors the original "arrow is down" state.
   * @returns {void}
   */
  expand() {
    setTimeout(() => {
      this.triggerTarget.setAttribute("aria-expanded", "true");
      this.listTarget.style.display = "block";
    }, 300);
  }

  /**
   * Collapses the dropdown after a 300ms delay.
   * Bound to the up arrow click; mirrors the original "arrow is up" state.
   * @returns {void}
   */
  collapse() {
    setTimeout(() => {
      this.triggerTarget.setAttribute("aria-expanded", "false");
      this.listTarget.style.display = "none";
    }, 300);
  }

  /**
   * Toggles the dropdown from keyboard activation on the trigger button.
   * Only reacts to Enter (keyCode 13) and Space (keyCode 32), and switches
   * based on the current `aria-expanded` value, each branch delayed by 300ms.
   * @param {KeyboardEvent} event - The keydown event fired on the trigger.
   * @returns {void}
   */
  toggle(event) {
    if (event.keyCode !== 13 && event.keyCode !== 32) {
      return;
    }

    if (this.triggerTarget.getAttribute("aria-expanded") === "true") {
      this.collapse();
    } else if (this.triggerTarget.getAttribute("aria-expanded") === "false") {
      this.expand();
    }
  }
}

SearchFilterDropdownController.targets = ["trigger", "arrowDown", "arrowUp", "list"]
