import { Controller } from "@hotwired/stimulus"

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

    // The server-rendered `aria-expanded="true"` fits desktop only; sync it
    // with the actual visibility (the CSS hides the list on small screens).
    if (window.getComputedStyle(this.listTarget).display === "none") {
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
