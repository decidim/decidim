import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller for the mobile search dropdown menu.
 *
 * Reproduces the close behavior of the mobile search menu: activating the close
 * element proxies a click to the external dropdown trigger
 * (`#dropdown-trigger-links-mobile-search`), which is what actually collapses the
 * mobile search. That trigger lives outside this partial and is therefore
 * resolved through `document.querySelector`, mirroring the original inline
 * implementation.
 */
export default class MobileSearchMenuController extends Controller {

  /**
   * Proxies a click to the external dropdown trigger to close the mobile search.
   * @returns {void}
   */
  close() {
    const dropdownTrigger = document.querySelector("#dropdown-trigger-links-mobile-search");
    if (dropdownTrigger) {
      dropdownTrigger.click();
    }
  }
}
