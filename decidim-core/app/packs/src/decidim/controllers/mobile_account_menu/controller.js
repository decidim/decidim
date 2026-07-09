import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller for the mobile account dropdown menu.
 *
 * Reproduces the accessible close behavior of the menu: keyboard activation
 * (Enter / Space) hides the menu and returns focus to the element that opens
 * it. The menu is this controller's element; on activation it loses its
 * `aria-modal` attribute, gains `aria-hidden="true"` and focus is moved back to
 * the external opening trigger, which lives outside this partial and is
 * therefore resolved through `document.querySelector`.
 */
export default class extends Controller {

  /**
   * Hides the menu and returns focus to the opening trigger. Only reacts to
   * Enter (keyCode 13) and Space (keyCode 32).
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
