import { Controller } from "@hotwired/stimulus"
import autofocus from "src/decidim/refactor/implementation/autofocus"

export default class extends Controller {

  connect() {
    if (this.element.querySelector("select.language-change, ul[data-controller='tabs']")) {
      autofocus(this.element)
    }
  }
}
