import { Controller } from "@hotwired/stimulus"
import autofocus from "src/decidim/refactor/implementation/autofocus"

export default class extends Controller {

  connect() {
    autofocus(this.element)
  }
}
