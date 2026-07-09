import { Controller } from "@hotwired/stimulus"

/**
 * Closes the mobile account dropdown menu on keyboard activation (Enter /
 * Space) of the close element and returns focus to the trigger that opened it.
 */
export default class extends Controller {
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
