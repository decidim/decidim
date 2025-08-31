import { Controller } from "@hotwired/stimulus"
import Accordions from "a11y-accordion-component";
import { screens } from "tailwindcss/defaultTheme"
export default class extends Controller {

  /**
   * Create accordion from a component
   *
   * @param {HTMLElement} component - The component to be created
   * @return {void}
   */
  connect() {
    this.toggleButton = this.element.querySelector("[data-controls]");

    const accordionOptions = {};
    accordionOptions.isMultiSelectable = this.element.dataset.multiselectable !== "false";
    accordionOptions.isCollapsible = this.element.dataset.collapsible !== "false";

    // This snippet allows to change the OPEN data-attribute based on the current viewport
    // Just include the breakpoint where the different value will be applied from.
    // Ex:
    // data-open="false" data-open-md="true"
    Object.keys(screens).forEach((key) => {
      if (!this.isScreenSize(key)) {
        return;
      }

      const elementsToOpen = this.element.querySelectorAll(`[data-controls][data-open-${key}]`);

      elementsToOpen.forEach((elem) => {
        (elem.dataset.open = elem.dataset[`open-${key}`.replace(/-([a-z])/g, (str) => str[1].toUpperCase())])
      })
    })

    if (!this.element.id) {
      // when component has no id, we enforce to have it one
      this.element.id = `accordion-${Math.random().toString(36).substring(7)}`
    }

    Accordions.render(this.element.id, accordionOptions);

    this.expandIfNeeded();

    this.boundReconnect = this.reconnect.bind(this);
    this.element.addEventListener("accordion:reconnect", this.boundReconnect);
  }

  disconnect() {
    if (!this.element.id) {
      return;
    }

    Accordions.destroy(this.element.id);

    if (this.boundReconnect) {
      this.element.removeEventListener("accordion:reconnect", this.boundReconnect);
    }

    if (this.boundExpand) {
      this.toggleButton.addEventListener("click", this.boundExpand);
    }
  }

  reconnect(event) {
    this.disconnect();

    if (event.detail && event.detail.collapse) {
      this.previouslyExpanded = false;
    }

    this.connect();
  }

  expandIfNeeded()
  {
    if (!this.toggleButton) {
      return;
    }

    if (this.previouslyExpanded) {
      this.toggleButton.dispatchEvent(new Event("click"));
    }

    this.boundExpand = this.expandToggle.bind(this);
    this.toggleButton.addEventListener("click", this.boundExpand)
  }
  expandToggle() {
    this.previouslyExpanded = this.toggleButton.getAttribute("aria-expanded");
  }

  /**
   * Checks if a key is in the current viewport
   *
   * @param {('sm'|'md'|'lg'|'xl'|'2xl')} key - The key to check the screen size.
   * @returns {boolean} - Returns true if the screen size corresponds with the key
   */
  isScreenSize(key) {
    return window.matchMedia(`(min-width: ${screens[key]})`).matches;
  }
}
