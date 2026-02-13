import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleChange = this.handleChange.bind(this);
    this.element.addEventListener("change", this.handleChange);
  }

  disconnect() {
    this.element.removeEventListener("change", this.handleChange)
  }

  handleChange(event) {
    let targetTabPaneSelector = event.target.value;
    let tabsContent = event.target.parentElement.parentElement.nextElementSibling;

    tabsContent.querySelector(".is-active").ariaHidden = "true";
    tabsContent.querySelector(".is-active").classList.remove("is-active");
    tabsContent.querySelector(targetTabPaneSelector).ariaHidden = "false";
    tabsContent.querySelector(targetTabPaneSelector).classList.add("is-active");
  }
}
