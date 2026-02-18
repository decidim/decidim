import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() {
    if (this.element.children.length) {
      const lastChild = [...this.element.children].pop()
      window.scrollTo({ top: lastChild.offsetTop, behavior: "smooth" });
    }
  }
}
