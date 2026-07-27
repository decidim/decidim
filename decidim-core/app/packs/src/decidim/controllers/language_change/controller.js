import { Controller } from "@hotwired/stimulus"
import autofocus from "src/decidim/refactor/implementation/autofocus"

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
    this.tabsContent = this.element.parentElement.parentElement.nextElementSibling;

    this.setActiveTab(this.element.value);
  }

  disconnect() {
    this.element.removeEventListener("change", this.handleChange)
  }

  setActiveTab(targetTabPaneSelector) {
    if (!this.tabsContent) {
      return;
    }

    let activeTabContent = this.tabsContent.querySelector(".is-active");
    if (activeTabContent) {
      activeTabContent.ariaHidden = "true";
      activeTabContent.classList.remove("is-active");
    }
    let activePane = this.tabsContent.querySelector(targetTabPaneSelector);
    if (activePane) {
      activePane.ariaHidden = "false";
      activePane.classList.add("is-active");
    }
  }

  handleChange(event) {
    this.setActiveTab(event.target.value);
    let activePane = this.tabsContent.querySelector(event.target.value);

    autofocus(activePane);
  }
}
