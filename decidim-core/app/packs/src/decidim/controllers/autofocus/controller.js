import { Controller } from "@hotwired/stimulus"
import autofocus from "src/decidim/refactor/implementation/autofocus"

export default class extends Controller {
  connect() {
    this.handleTabsChange = this.handleTabsChange.bind(this)

    // Foundation tabs (used for translated fields when locales <= 4)
    this.tabs = Array.from(this.element.querySelectorAll("ul[data-tabs]"))
    if (typeof $ === "function" && this.tabs.length > 0) {
      this.tabs.forEach((tabs) => $(tabs).on("change.zf.tabs", this.handleTabsChange))
    }

    // Language selector dropdown (used for translated fields when locales > 4)
    if (this.element.querySelector("select.language-change")) {
      autofocus(this.element)
    }
  }

  disconnect() {
    if (typeof $ === "function" && this.tabs && this.tabs.length > 0) {
      this.tabs.forEach((tabs) => $(tabs).off("change.zf.tabs", this.handleTabsChange))
    }
  }

  handleTabsChange(event) {
    const activePane = $(event.target).parent().next(".tabs-content").find(".tabs-panel.is-active")[0]
    autofocus(activePane)
  }
}
