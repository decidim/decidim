import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.input =  this.element.querySelector("input");
    this.target = this.element.querySelector("span.slug-url-value");
    this.boundUpdate = null;

    if (this.input) {
      this.boundUpdate = this.slugUpdater.bind(this);
      this.input.addEventListener("keyup", this.boundUpdate)
    }
  }

  disconnect() {
    if (this.boundUpdate !== null) {
      this.input.removeEventListener("keyup", this.boundUpdate)
      this.boundUpdate = null;
    }
  }

  slugUpdater(event) {
    this.target.innerHTML = event.target.value;
  }
}
