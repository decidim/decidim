import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.dropdownMobileDiv = document.querySelector("#dropdown-menu-account-mobile");

    this.handleClick = this.handleClick.bind(this);
    this.element.addEventListener("click", this.handleClick);
  }

  disconnect() {
    this.element.removeEventListener("click", this.handleClick)
  }

  handleClick() {
    if (!this.dropdownMobileDiv) {
      return;
    }
    this.dropdownMobileDiv.setAttribute("aria-modal", "true")
  }

}
