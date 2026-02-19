import { Controller } from "@hotwired/stimulus"

/**
 * This controller is used to change the active tab when the language is changed in the admin or system panel.
 * It uses a select element to list the languages available in the platform and adds an observer that would set
 * the tab the active tab to what is selected in the select element by toggling the aria-hidden attribute on the
 * tab container.
 */
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
