import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!navigator.onLine && !document.querySelector("#offline-fallback-html")) {
      this.element.style.display = "block";
    }
  }
}
