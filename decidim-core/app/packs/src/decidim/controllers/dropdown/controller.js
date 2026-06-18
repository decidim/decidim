import { Controller } from "@hotwired/stimulus"
import { screens } from "tailwindcss/defaultTheme"
import Dropdowns from "a11y-dropdown-component";

const DROPDOWN_FOCUSABLE_SELECTOR = "a[href],button:not([disabled]),input:not([disabled]),select:not([disabled]),textarea:not([disabled])"

/**
 * Create dropdown from a component
 *
 * @param {HTMLElement} component - The component to be created
 * @returns {void}
 */
export default class extends Controller {
  connect() {
    const dropdownOptions = {};
    dropdownOptions.dropdown = this.element.dataset.target;
    dropdownOptions.hover = this.element.dataset.hover === "true";
    dropdownOptions.autoClose = this.element.dataset.autoClose === "true";

    // This snippet allows to disable the dropdown based on the current viewport
    // Just include the breakpoint where the different value will be applied from.
    // Ex:
    // data-disabled-md="true"
    const isDisabled = Object.keys(screens).some((key) => {
      if (!this.isScreenSize(key)) {
        return false;
      }

      return Boolean(this.element.dataset[`disabled-${key}`.replace(/-([a-z])/g, (str) => str[1].toUpperCase())]);
    })

    if (isDisabled) {
      return
    }

    dropdownOptions.isOpen = this.element.dataset.open === "true";

    const isOpen = Object.keys(screens).some((key) => {
      if (!this.isScreenSize(key)) {
        return false;
      }
      return Boolean(this.element.dataset[`open-${key}`.replace(/-([a-z])/g, (str) => str[1].toUpperCase())]);
    });

    dropdownOptions.isOpen = dropdownOptions.isOpen || isOpen;

    if (!this.element.id) {
      // when component has no id, we enforce to have it one
      this.element.id = `dropdown-${Math.random().toString(36).substring(7)}`
    }

    const autofocus = this.element.dataset.autofocus;
    if (autofocus) {
      // set the focus to some inner element, use setTimeout hack due to waiting for element to display
      this.element.addEventListener("click", () => setTimeout(() => document.getElementById(autofocus).focus(), 0));
    }

    const scrollToMenu = this.element.dataset.scrollToMenu === "true";
    if (scrollToMenu) {
      // Auto scroll to show the menu on the viewport
      this.element.addEventListener("click", (event) => {
        const heightToScroll = this.element.getBoundingClientRect().top + window.scrollY + document.documentElement.clientTop;
        const isCollapsed = event.target.getAttribute("aria-expanded") === "false";

        if (isCollapsed) {
          return;
        }

        window.scrollTo({ top: heightToScroll, behavior: "smooth" });
      });
    }

    // Fixes styles for dropdowns with child dropdowns
    const hasChildMenu = this.element.parentNode.classList.contains("dropdown__item")
    if (hasChildMenu) {
      this.changeChildMenuDropdownPosition();
      this.changeStyleOfSelectedElement();
    }

    Dropdowns.render(this.element.id, dropdownOptions);

    const addAriaRoles = this.element.dataset.addAriaRoles !== "false";
    if (!addAriaRoles) {
      this.removeAriaRoles();
    }

    if (this.element.dataset.focusTrap === "true") {
      this.setupFocusTrap();
    }
  }

  disconnect() {
    this.teardownFocusTrap();
  }

  setupFocusTrap() {
    this.dropdownMenu = document.getElementById(this.element.dataset.target);

    if (!this.dropdownMenu) {
      return;
    }

    this.focusTrapEnabled = false;
    this.handleFocusTrapKeydown = this.handleFocusTrapKeydown.bind(this);
    this.focusTrapObserver = new MutationObserver(() => this.syncFocusTrap());
    this.focusTrapObserver.observe(this.dropdownMenu, { attributes: true, attributeFilter: ["aria-hidden"] });
    this.syncFocusTrap();
  }

  teardownFocusTrap() {
    this.disableFocusTrap();
    this.focusTrapObserver?.disconnect();
  }

  isDropdownOpen() {
    return this.dropdownMenu?.getAttribute("aria-hidden") === "false";
  }

  syncFocusTrap() {
    if (this.isDropdownOpen()) {
      this.enableFocusTrap();
    } else {
      this.disableFocusTrap();
    }
  }

  getFocusableElements() {
    return Array.from(this.dropdownMenu.querySelectorAll(DROPDOWN_FOCUSABLE_SELECTOR)).filter(
      (element) => !element.disabled && (element.offsetWidth > 0 || element.offsetHeight > 0)
    );
  }

  handleFocusTrapKeydown(event) {
    if (!this.isDropdownOpen() || event.key !== "Tab") {
      return;
    }

    const focusable = this.getFocusableElements();

    if (focusable.length === 0) {
      return;
    }

    const firstElement = focusable[0];
    const lastElement = focusable[focusable.length - 1];

    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault();
      lastElement.focus({ preventScroll: true });
    } else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault();
      firstElement.focus({ preventScroll: true });
    }
  }

  enableFocusTrap() {
    if (this.focusTrapEnabled) {
      return;
    }

    this.focusTrapEnabled = true;
    document.addEventListener("keydown", this.handleFocusTrapKeydown);

    if (window.focusGuard) {
      window.focusGuard.trap(this.dropdownMenu, this.element);
    }

    const focusable = this.getFocusableElements();
    if (focusable.length > 0) {
      focusable[0].focus({ preventScroll: true });
    }
  }

  disableFocusTrap() {
    if (!this.focusTrapEnabled) {
      return;
    }

    this.focusTrapEnabled = false;
    document.removeEventListener("keydown", this.handleFocusTrapKeydown);

    if (window.focusGuard) {
      window.focusGuard.disable();
    }
  }

  removeAriaRoles() {
    const target = this.element.dataset.target;
    const dropdownMenu = document.getElementById(target);
    if (!dropdownMenu) {
      return;
    }

    dropdownMenu.removeAttribute("role");
    dropdownMenu.removeAttribute("aria-labelledby");
    dropdownMenu.removeAttribute("tabindex");

    dropdownMenu.querySelectorAll("li").forEach((li) => {
      li.removeAttribute("role");
    });

    dropdownMenu.querySelectorAll("a").forEach((anchor) => {
      anchor.removeAttribute("role");
      anchor.removeAttribute("tabindex");
    });
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

  /*
   * Changes the Child Menu dropdown position when there are multiple children Dropdowns.
   * This is used when there is a tree of dropdowns, such as in the Filters feature with Taxonomies.
   * It changs the position of the child menu taking into account the width of the parent
   * (that it is not the same always).
   */
  changeChildMenuDropdownPosition() {
    const target = this.element.dataset.target;
    const childMenu = document.getElementById(target);
    const parentMenu = this.element.parentNode.parentNode;

    const observer = new MutationObserver(() => {
      if (childMenu.style.display !== "none" && parentMenu.offsetWidth !== 0) {
        const positionLeft = parentMenu.offsetWidth - 10;

        childMenu.style.left = `${positionLeft}px`;
      }
    });

    observer.observe(childMenu, { attributes: true, childList: true });
  }

  /*
   * Changes the style of the selected element when there are children Dropdowns
   */
  changeStyleOfSelectedElement() {
    this.element.addEventListener("click", function(event) {
      event.target.parentNode.parentNode.querySelectorAll("a").forEach((link) => {
        link.parentNode.classList.remove("dropdown__item-opened");
      })

      event.target.parentNode.classList.add("dropdown__item-opened")
    })
  }
}
