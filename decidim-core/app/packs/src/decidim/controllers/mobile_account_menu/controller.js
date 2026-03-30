import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["closeButton"]
  static values = { menuId: String, triggerId: String }

  closeOnKey(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      const menu = document.getElementById(this.menuIdValue);
      const trigger = document.getElementById(this.triggerIdValue);

      if (menu) {
        menu.removeAttribute("aria-modal");
        menu.setAttribute("aria-hidden", "true");
      }
      if (trigger) {
        trigger.focus();
      }
    }
  }
}
