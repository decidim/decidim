import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() {
    return ["button", "list"]
  }

  toggle() {
    const expanded = this.buttonTarget.getAttribute("aria-expanded") === "true";
    setTimeout(() => {
      if (expanded) {
        this.buttonTarget.setAttribute("aria-expanded", "false");
        this.listTarget.style.display = "none";
      } else {
        this.buttonTarget.setAttribute("aria-expanded", "true");
        this.listTarget.style.display = "block";
      }
    }, 300);
  }

  toggleFromKeyboard(event) {
    if (event.key !== "Enter" && event.key !== " ") {
      return;
    }
    event.preventDefault();
    this.toggle();
  }
}
