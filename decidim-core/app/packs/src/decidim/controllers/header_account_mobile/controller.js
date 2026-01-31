import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const dropdownMobileDiv = document.querySelector("#dropdown-menu-account-mobile");

    this.element.addEventListener("click", () => {
      dropdownMobileDiv.setAttribute("aria-modal", "true")
    })
  }
}
