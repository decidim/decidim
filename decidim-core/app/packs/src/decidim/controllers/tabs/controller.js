import { Controller } from "@hotwired/stimulus";

/**
 * This JavaScript is taken from the following link:
 * https://www.w3.org/WAI/ARIA/apg/patterns/tabs/examples/tabs-automatic/
 *
 * To which i have converted it to a Stimulus controller, trying to keep decidim structure.
 * We keep the same HTML structure as on foundation, but we are replacing with a truly accessible tabs implementation.
 */

export default class TabsController extends Controller {
  connect() {
    this.tabs = Array.from(this.element.querySelectorAll("[role=tab]"));

    this.tabpanels = [];
    this.firstTab = null;
    this.lastTab = null;

    this._onKeydown = this.onKeydown.bind(this);
    this._onClick = this.onClick.bind(this);

    for (let index = 0; index < this.tabs.length; index += 1) {
      let tab = this.tabs[index];
      let tabpanel = document.getElementById(tab.getAttribute("aria-controls"));

      if (tabpanel) {
        tab.tabIndex = -1;
        tab.setAttribute("aria-selected", "false");
        this.tabpanels.push(tabpanel);
        tab.addEventListener("keydown", this._onKeydown);
        tab.addEventListener("click", this._onClick);
        if (!this.firstTab) {
          this.firstTab = tab;
        }
        this.lastTab = tab;
      } else {
        console.error(`Tab at index ${index} references a nonexistent panel:`, tab.getAttribute("aria-controls"));
      }
    }
    this.detectAndSetActiveTab();
  }

  detectAndSetActiveTab() {
    let activeLiItem = this.element.querySelector(".is-active");
    if (activeLiItem) {
      let link = activeLiItem.querySelector("a");
      if (link) {
        this.setSelectedTab(link, false);
      }
    } else {
      this.setSelectedTab(this.firstTab, false);
    }
  }

  disconnect() {
    for (let tab of this.tabs) {
      tab.removeEventListener("keydown", this._onKeydown);
      tab.removeEventListener("click", this._onClick);
    }
  }

  setSelectedTab(currentTab, setFocus) {
    if (typeof setFocus !== "boolean") {
      // eslint-disable-next-line no-param-reassign
      setFocus = true;
    }
    for (let index = 0; index < this.tabs.length; index += 1) {
      let tab = this.tabs[index];
      if (currentTab === tab) {
        this.setActiveTab(tab)
        this.tabpanels[index].classList.remove("is-hidden");
        this.tabpanels[index].setAttribute("aria-hidden", "false");
        if (setFocus && tab) {
          tab.focus();
        }
      } else {
        this.setInactiveTab(tab)
        this.tabpanels[index].classList.add("is-hidden");
        this.tabpanels[index].setAttribute("aria-hidden", "true");
      }
    }
  }

  setInactiveTab(tab) {
    if (!tab) {
      return;
    }
    tab.parentNode.classList.remove("is-active");
    tab.setAttribute("aria-selected", "false");
    tab.tabIndex = -1;
  }

  setActiveTab(tab) {
    if (!tab) {
      return;
    }
    tab.setAttribute("aria-selected", "true");
    tab.removeAttribute("tabindex");
    tab.parentNode.classList.add("is-active");
  }

  setSelectedToPreviousTab(currentTab) {
    if (currentTab === this.firstTab) {
      this.setSelectedTab(this.lastTab);
    } else {
      let index = this.tabs.indexOf(currentTab);
      this.setSelectedTab(this.tabs[index - 1]);
    }
  }

  setSelectedToNextTab(currentTab) {
    if (currentTab === this.lastTab) {
      this.setSelectedTab(this.firstTab);
    } else {
      let index = this.tabs.indexOf(currentTab);
      this.setSelectedTab(this.tabs[index + 1]);
    }
  }

  /* EVENT HANDLERS */

  onKeydown(event) {
    let tgt = event.currentTarget;
    let flag = false;

    switch (event.key) {
    case "ArrowLeft":
      this.setSelectedToPreviousTab(tgt);
      flag = true;
      break;

    case "ArrowRight":
      this.setSelectedToNextTab(tgt);
      flag = true;
      break;

    case "Home":
      this.setSelectedTab(this.firstTab);
      flag = true;
      break;

    case "End":
      this.setSelectedTab(this.lastTab);
      flag = true;
      break;

    default:
      break;
    }

    if (flag) {
      event.stopPropagation();
      event.preventDefault();
    }
  }

  onClick(event) {
    this.setSelectedTab(event.currentTarget);

    event.stopPropagation();
    event.preventDefault();
  }
}
