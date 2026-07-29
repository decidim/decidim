import { Controller } from "@hotwired/stimulus"
import Accordions from "a11y-accordion-component";
import { screens } from "tailwindcss/defaultTheme"
export default class extends Controller {
  initialize() {
    this._originalOpenValues = new WeakMap();
  }

  /**
   * Create accordion from a component
   *
   * @param {HTMLElement} component - The component to be created
   * @returns {void}
   */
  connect() {
    this.toggleButton = this.element.querySelector("[data-controls]");

    const accordionOptions = {};
    accordionOptions.isMultiSelectable = this.element.dataset.multiselectable !== "false";
    accordionOptions.isCollapsible = this.element.dataset.collapsible !== "false";

    this._applyBreakpointOpenAttributes();
    this._listenForBreakpointChanges();

    if (!this.element.id) {
      // when component has no id, we enforce to have it one
      this.element.id = `accordion-${Math.random().toString(36).substring(7)}`
    }

    Accordions.render(this.element.id, accordionOptions);

    this.fixPanelRole();

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
      this.toggleButton.removeEventListener("click", this.boundExpand);
    }

    this._stopListeningForBreakpointChanges();
  }

  reconnect(event) {
    this.disconnect();

    if (event && event.detail && event.detail.collapse) {
      this.previouslyExpanded = false;
    }

    this.connect();
  }

  /**
   * Applies viewport-conditional data-open attributes and resets
   * previously applied values when the viewport no longer matches.
   *
   * @returns {void}
   */
  _applyBreakpointOpenAttributes() {
    const controlledTriggers = new Set();

    Object.keys(screens).forEach((key) => {
      this.element.querySelectorAll(`[data-controls][data-open-${key}]`).forEach((elem) => {
        controlledTriggers.add(elem);

        if (!this._originalOpenValues.has(elem)) {
          this._originalOpenValues.set(elem, elem.getAttribute("data-open"));
        }
      });
    });

    // Reset all controlled triggers to their original data-open state
    controlledTriggers.forEach((elem) => {
      const original = this._originalOpenValues.get(elem);
      if (original === null) {
        elem.removeAttribute("data-open");
      } else {
        elem.setAttribute("data-open", original);
      }
    });

    // Apply breakpoint-specific values for the current viewport
    Object.keys(screens).forEach((key) => {
      if (!this.isScreenSize(key)) {
        return;
      }

      this.element.querySelectorAll(`[data-controls][data-open-${key}]`).forEach((elem) => {
        elem.dataset.open = elem.getAttribute(`data-open-${key}`);
      });
    });
  }

  /**
   * Listens for viewport changes that cross breakpoints relevant
   * to this accordion and reconnects to keep state in sync.
   *
   * @returns {void}
   */
  _listenForBreakpointChanges() {
    this._mediaQueries = [];

    Object.keys(screens).forEach((key) => {
      const hasRelevantTriggers = this.element.querySelector(`[data-controls][data-open-${key}]`);
      if (!hasRelevantTriggers) {
        return;
      }

      const mql = window.matchMedia(`(min-width: ${screens[key]})`);
      const handler = () => {
        this.reconnect({ detail: { collapse: true } });
      };

      if (mql.addEventListener) {
        mql.addEventListener("change", handler);
      } else if (mql.addListener) {
        mql.addListener(handler);
      }

      this._mediaQueries.push({ mql, handler });
    });
  }

  _stopListeningForBreakpointChanges() {
    if (this._mediaQueries) {
      this._mediaQueries.forEach(({ mql, handler }) => {
        if (mql.removeEventListener) {
          mql.removeEventListener("change", handler);
        } else if (mql.removeListener) {
          mql.removeListener(handler);
        }
      });
      this._mediaQueries = [];
    }
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

  fixPanelRole() {
    const panelRole = this.element.dataset.panelRole;
    if (!panelRole) {
      return;
    }

    const panels = this.element.querySelectorAll("[data-controls]");
    panels.forEach((trigger) => {
      const panelId = trigger.dataset.controls;
      const panel = document.getElementById(panelId);
      if (!panel) {
        return;
      }

      if (panelRole === "none") {
        panel.removeAttribute("role");
      } else {
        panel.setAttribute("role", panelRole);
      }
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
}
