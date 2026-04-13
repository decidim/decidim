import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const checkbox = event.target;
    const handler = document.getElementById(`authorization-handler-${checkbox.value}`);
    if (handler) {
      handler.style.display = checkbox.checked
        ? "block"
        : "none";
    }
  }
}
