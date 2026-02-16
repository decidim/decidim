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

    if (!tabsContent) {
      return;
    }

    let activeTabContent = tabsContent.querySelector(".is-active");
    if (activeTabContent) {
      activeTabContent.ariaHidden = "true";
      activeTabContent.classList.remove("is-active");
    }
    let activePane = tabsContent.querySelector(targetTabPaneSelector);
    if (activePane) {
      activePane.ariaHidden = "false";
      activePane.classList.add("is-active");
    }
  }
}
