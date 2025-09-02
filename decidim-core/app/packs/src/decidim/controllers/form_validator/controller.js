import { Controller } from "@hotwired/stimulus"
import FormValidator from "src/decidim/controllers/form_validator/form_validator"

export default class extends Controller {

  connect() {
    if (!this.element.dataset.formValidator) {
      this.formValidator = new FormValidator(this.element, {
        liveValidate: this.element.dataset.liveValidate === "true",
        validateOnBlur: this.element.dataset.validateOnBlur === "true"
      });
      this.element.dataset.formValidator = true
    }
  }

  disconnect() {
    if (!this.formValidator) {
      return;
    }
    this.formValidator.destroyValidator()
  }
}

