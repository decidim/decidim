import { Keyboard } from "foundation-sites"

const focusGuardClass = "focusguard";
const focusableNodes = ["A", "IFRAME", "OBJECT", "EMBED"];
const focusableDisableableNodes = ["BUTTON", "INPUT", "TEXTAREA", "SELECT"];

export default class FocusGuard {
  constructor(container) {
    this.container = container;
    this.guardedElement = null;
  }

  trap(element) {
    if (this.guardedElement) {
      Keyboard.releaseFocus($(this.guardedElement));
    }

    this.enable();
    this.guardedElement = element;

    // Call the release focus first so that we don't accidentally add the
    // keyboard trap twice. Note that the Foundation methods expect the elements
    // to be jQuery elements which is why we pass them through jQuery.
    Keyboard.releaseFocus($(element));
    Keyboard.trapFocus($(element));
  }

  enable() {
    // Check if the guards already exists due to some other dialog
    const guards = this.container.querySelectorAll(`:scope > .${focusGuardClass}`);
    if (guards.length > 0) {
      // Make sure the guards are the first and last element as there have
      // been changes in the DOM.
      guards.forEach((guard) => {
        if (guard.dataset.position === "start") {
          this.container.prepend(guard);
        } else {
          this.container.append(guard);
        }
      })

      return;
    }

    // Add guards at the start and end of the document and attach their focus
    // listeners
    const startGuard = this.createFocusGuard("start");
    const endGuard = this.createFocusGuard("end");

    this.container.prepend(startGuard);
    this.container.append(endGuard);

    startGuard.addEventListener("focus", () => this.handleContainerFocus(startGuard));
    endGuard.addEventListener("focus", () => this.handleContainerFocus(endGuard));
  }

  disable() {
    const guards = this.container.querySelectorAll(`:scope > .${focusGuardClass}`);
    guards.forEach((guard) => guard.remove());

    if (this.guardedElement) {
      // Note that the Foundation methods expect the elements to be jQuery
      // elements which is why we pass them through jQuery.
      Keyboard.releaseFocus($(this.guardedElement));
      this.guardedElement = null;
    }
  }

  createFocusGuard(position) {
    const guard = document.createElement("div");
    guard.className = focusGuardClass;
    guard.dataset.position = position;
    guard.tabIndex = 0;
    guard.setAttribute("aria-hidden", "true");

    return guard;
  };

  handleContainerFocus(guard) {
    if (!this.guardedElement) {
      guard.blur();
      return;
    }

    const visibleNodes = Array.from(this.guardedElement.querySelectorAll("*")).filter((item) => {
      return this.isVisible(item);
    });

    let target = null;
    if (guard.dataset.position === "start") {
      // Focus at the start guard, so focus the first focusable element after that
      for (let ind = 0; ind < visibleNodes.length; ind += 1) {
        if (!this.isFocusGuard(visibleNodes[ind]) && this.isFocusable(visibleNodes[ind])) {
          target = visibleNodes[ind];
          break;
        }
      }
    } else {
      // Focus at the end guard, so focus the first focusable element after that
      for (let ind = visibleNodes.length - 1; ind >= 0; ind -= 1) {
        if (!this.isFocusGuard(visibleNodes[ind]) && this.isFocusable(visibleNodes[ind])) {
          target = visibleNodes[ind];
          break;
        }
      }
    }

    if (target) {
      target.focus();
    } else {
      // If no focusable element was found, blur the guard focus
      guard.blur();
    }
  };

  isVisible(element) {
    return element.offsetWidth > 0 || element.offsetHeight > 0;
  }

  isFocusGuard(element) {
    return element.classList.contains(focusGuardClass);
  }

  isFocusable(element) {
    if (focusableNodes.indexOf(element.nodeName) > -1) {
      return true;
    }
    if (focusableDisableableNodes.indexOf(element.nodeName) > -1 || element.getAttribute("contenteditable")) {
      if (element.getAttribute("disabled")) {
        return false;
      }
      return true;
    }

    const tabindex = parseInt(element.getAttribute("tabindex"), 10);
    if (!isNaN(tabindex) && tabindex >= 0) {
      return true;
    }

    return false;
  }
}
