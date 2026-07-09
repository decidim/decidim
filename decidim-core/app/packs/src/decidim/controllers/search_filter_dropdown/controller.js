import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller for the global search results filter dropdown.
 *
 * The trigger button holds the `aria-expanded` state and the menu list its
 * visibility. The two chevron icons inside the button drive the state (the down
 * arrow expands, the up arrow collapses) and keyboard activation on the button
 * (Enter / Space) toggles it. Every state change is intentionally delayed by
 * 300ms to mirror the previous inline implementation.
 */
export default class extends Controller {
  static get targets() {
    return ["trigger", "list"]
  }

  connect() {
    this.expand = this.expand.bind(this);
    this.collapse = this.collapse.bind(this);

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
