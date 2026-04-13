import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get values() {
    return { target: String }
  }

  sync() {
    const input = document.querySelector(`input[name='${this.targetValue}']`);
    if (input) {
      input.value = this.element.options[this.element.selectedIndex].text;
    }
  }
}
