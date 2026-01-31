import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const dropdownMobileDiv = document.querySelector("#dropdown-menu-account-mobile");

    setTimeout(() => {
      this.element.setAttribute("role", "dialog")
      dropdownMobileDiv.setAttribute("role", "dialog")
    }, 300)
  }
}
