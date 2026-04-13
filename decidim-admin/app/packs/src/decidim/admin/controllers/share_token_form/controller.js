import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() {
    return ["wrapper", "input", "radio"]
  }

  static get values() {
    return { showWhen: String }
  }

  connect() {
    this.toggle();
  }

  toggle() {
    const checked = this.radioTargets.find((radio) => radio.checked);
    if (!checked) {
      return;
    }

    if (checked.value === this.showWhenValue) {
      this.wrapperTarget.classList.remove("hidden");
      if (this.hasInputTarget) {
        this.inputTarget.focus();
      }
    } else {
      this.wrapperTarget.classList.add("hidden");
      if (this.hasInputTarget) {
        this.inputTarget.value = "";
        this.inputTarget.removeAttribute("required");
      }
    }
  }
}
