import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get values() {
    return { panel: String }
  }

  toggle() {
    const panel = document.querySelector(this.panelValue);
    if (panel) {
      panel.toggleAttribute("inert");
    }
  }

  toggleOnKey(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      this.toggle();
    }
  }
}
