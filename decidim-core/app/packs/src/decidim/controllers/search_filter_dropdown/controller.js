import { Controller } from "@hotwired/stimulus"
import { screens } from "tailwindcss/defaultTheme"

/**
 * Expands / collapses the global search results filter list through the two
 * chevron icons of the trigger button and through keyboard activation (Enter /
 * Space) on the button, keeping `aria-expanded` in sync.
 *
 * Targets:
 *   - `trigger` – The dropdown trigger button holding `aria-expanded`.
 *   - `list` – The filter list whose visibility is toggled.
 */
export default class extends Controller {
  static get targets() {
    return ["trigger", "list"]
  }

  connect() {
    this.expand = this.expand.bind(this);
    this.collapse = this.collapse.bind(this);

    // The server renders `aria-expanded="true"` for the desktop layout, where
    // the list is always visible. On small screens the list starts hidden, so
    // the attribute is corrected to keep the chevrons and the toggle direction
    // in sync with the actual state.
    if (!window.matchMedia(`(min-width: ${screens.md})`).matches) {
      this.triggerTarget.setAttribute("aria-expanded", "false");
    }

    // The `icon` helper strips `data-*` attributes, so the chevron listeners
    // cannot be declared on the svg and are wired here instead.
    this.arrowDown = this.triggerTarget.querySelector("svg:first-of-type");
    this.arrowUp = this.triggerTarget.querySelector("svg:last-of-type");

    if (this.arrowDown) {
      this.arrowDown.addEventListener("click", this.expand);
    }
    if (this.arrowUp) {
      this.arrowUp.addEventListener("click", this.collapse);
    }
  }

  disconnect() {
    if (this.arrowDown) {
      this.arrowDown.removeEventListener("click", this.expand);
    }
    if (this.arrowUp) {
      this.arrowUp.removeEventListener("click", this.collapse);
    }
  }

  expand() {
    setTimeout(() => {
      this.triggerTarget.setAttribute("aria-expanded", "true");
      this.listTarget.style.display = "block";
    }, 300);
  }

  collapse() {
    setTimeout(() => {
      this.triggerTarget.setAttribute("aria-expanded", "false");
      this.listTarget.style.display = "none";
    }, 300);
  }

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
