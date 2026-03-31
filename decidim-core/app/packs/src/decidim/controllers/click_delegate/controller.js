import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get values() {
    return {
      target: String,
      class: String
    }
  }

  delegate() {
    const target = document.querySelector(this.targetValue);
    if (target) {
      target.click();
    }
  }

  reload() {
    location.reload();
  }

  toggleClass() {
    document.body.classList.toggle(this.classValue);
  }

  submitForm() {
    this.element.form.submit();
  }
}
