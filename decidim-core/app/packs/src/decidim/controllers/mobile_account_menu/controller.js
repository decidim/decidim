import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller for the mobile account dropdown menu.
 *
 * Reproduces the accessible close behavior of the mobile account menu: keyboard
 * activation (Enter / Space) on the close element hides the menu and returns
 * focus to the element that opens it. The menu (`#dropdown-menu-account-mobile`)
 * is this controller's element; on activation it loses its `aria-modal`
 * attribute, gains `aria-hidden="true"` and focus is moved back to the external
 * opening trigger (`#dropdown-trigger-links-mobile`), which lives outside this
 * partial and is therefore resolved through `document.querySelector`.
 *
 * Targets:
 *   - `close` – The close element inside the menu that holds keyboard focus.
 */
export default class MobileAccountMenuController extends Controller {

  /**
   * Hides the menu and returns focus to the opening trigger from keyboard
   * activation on the close element. Only reacts to Enter (keyCode 13) and
   * Space (keyCode 32), mirroring the original inline implementation.
   * @param {KeyboardEvent} event - The keydown event fired on the close element.
   * @returns {void}
   */
  close(event) {
    // 32 is code for space bar and 13 is code for enter
    if (event.keyCode !== 13 && event.keyCode !== 32) {
      return;
    }

    this.element.removeAttribute("aria-modal");
    this.element.setAttribute("aria-hidden", "true");

    const dropdownTrigger = document.querySelector("#dropdown-trigger-links-mobile");
    if (dropdownTrigger) {
      dropdownTrigger.focus();
    }
  }
}

MobileAccountMenuController.targets = ["close"]
