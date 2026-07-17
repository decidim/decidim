import { Controller } from "@hotwired/stimulus"

/**
 * Reveals a truncated content block description by toggling the `inert`
 * attribute on the panel referenced by the button's `data-controls` value.
 * Mounted on the "view more" button itself: a second controller on the
 * accordion container would break its exact-match `data-controller` styles.
 */
export default class extends Controller {
  toggle(event) {
    // 32 is code for space bar and 13 is code for enter
    if (event.type === "keydown" && event.keyCode !== 13 && event.keyCode !== 32) {
      return;
    }

    const panel = document.getElementById(this.element.getAttribute("data-controls"));
    if (panel) {
      panel.toggleAttribute("inert");
    }
  }
}
