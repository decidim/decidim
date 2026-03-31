import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundInit = this.init.bind(this);
    document.addEventListener("turbo:load", this.boundInit, { once: true });
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.boundInit);
  }

  init() {
    if (window.Decidim && window.Decidim.createEditableForm) {
      window.Decidim.createEditableForm();
    }
  }
}
