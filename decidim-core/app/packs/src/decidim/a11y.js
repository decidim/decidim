import Accordions from "a11y-accordion-component";
import Dropdowns from "a11y-dropdown-component";
import Dialogs from "a11y-dialog-component";
import { screens } from "tailwindcss/defaultTheme"


/**
 * Checks if a key is in the current viewport
 *
 * @param {('sm'|'md'|'lg'|'xl'|'2xl')} key - The key to check the screen size.
 * @returns {boolean} - Returns true if the screen size corresponds with the key
 */
const isScreenSize = (key) => {
  return window.matchMedia(`(min-width: ${screens[key]})`).matches;
}

/**
 * Create accordion from a component
 *
 * @param {HTMLElement} component - The component to be created
 * @return {void}
 */
const createAccordion = (component) => {
  const accordionOptions = {};
  accordionOptions.isMultiSelectable = component.dataset.multiselectable !== "false";
  accordionOptions.isCollapsible = component.dataset.collapsible !== "false";

  // This snippet allows to change the OPEN data-attribute based on the current viewport
  // Just include the breakpoint where the different value will be applied from.
  // Ex:
  // data-open="false" data-open-md="true"
  Object.keys(screens).forEach((key) => {
    if (!isScreenSize(key)) {
      return;
    }

    const elementsToOpen = component.querySelectorAll(`[data-controls][data-open-${key}]`);

    elementsToOpen.forEach((elem) => {
      (elem.dataset.open = elem.dataset[`open-${key}`.replace(/-([a-z])/g, (str) => str[1].toUpperCase())])
    })
  })

  if (!component.id) {
    // when component has no id, we enforce to have it one
    component.id = `accordion-${Math.random().toString(36).substring(7)}`
  }

  Accordions.render(component.id, accordionOptions);
}

/*
 * Changes the Child Menu dropdown position when there are multiple children Dropdowns.
 * This is used when there is a tree of dropdowns, such as in the Filters feature with Taxonomies.
 * It changs the position of the child menu taking into account the width of the parent
 * (that it is not the same always).
 */
const changeChildMenuDropdownPosition = (component) => {
  const target = component.dataset.target;
  const childMenu = document.getElementById(target);
  const parentMenu = component.parentNode.parentNode;

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
const changeStyleOfSelectedElement = (component) => {
  component.addEventListener("click", function() {
    component.parentNode.parentNode.querySelectorAll("a").forEach((link) => {
      link.style.fontWeight = "normal";
    })

    component.style.fontWeight = 600;
  })
}

/**
 * Create dropdown from a component
 *
 * @param {HTMLElement} component - The component to be created
 * @return {void}
 */
const createDropdown = (component) => {
  const dropdownOptions = {};
  dropdownOptions.dropdown = component.dataset.target;
  dropdownOptions.hover = component.dataset.hover === "true";
  dropdownOptions.autoClose = component.dataset.autoClose === "true";

  // This snippet allows to disable the dropdown based on the current viewport
  // Just include the breakpoint where the different value will be applied from.
  // Ex:
  // data-disabled-md="true"
  const isDisabled = Object.keys(screens).some((key) => {
    if (!isScreenSize(key)) {
      return false;
    }

    return Boolean(component.dataset[`disabled-${key}`.replace(/-([a-z])/g, (str) => str[1].toUpperCase())]);
  })

  if (isDisabled) {
    return
  }

  dropdownOptions.isOpen = component.dataset.open === "true";

  const isOpen = Object.keys(screens).some((key) => {
    if (!isScreenSize(key)) {
      return false;
    }
    return Boolean(component.dataset[`open-${key}`.replace(/-([a-z])/g, (str) => str[1].toUpperCase())]);
  });

  dropdownOptions.isOpen = dropdownOptions.isOpen || isOpen;

  if (!component.id) {
    // when component has no id, we enforce to have it one
    component.id = `dropdown-${Math.random().toString(36).substring(7)}`
  }

  const autofocus = component.dataset.autofocus;
  if (autofocus) {
    // set the focus to some inner element, use setTimeout hack due to waiting for element to display
    component.addEventListener("click", () => setTimeout(() => document.getElementById(autofocus).focus(), 0));
  }

  const scrollToMenu = component.dataset.scrollToMenu === "true";
  if (scrollToMenu) {
    // Auto scroll to show the menu on the viewport
    component.addEventListener("click", (event) => {
      const heightToScroll = component.getBoundingClientRect().top + window.scrollY + document.documentElement.clientTop;
      const isCollapsed = event.target.getAttribute("aria-expanded") === "false";

      if (isCollapsed) {
        return;
      }

      window.scrollTo({ top: heightToScroll, behavior: "smooth" });
    });
  }

  // Fixes styles for dropdowns with child dropdowns
  const hasChildMenu = component.classList.contains("dropdown__item")
  if (hasChildMenu) {
    changeChildMenuDropdownPosition(component);
    changeStyleOfSelectedElement(component);
  }

  Dropdowns.render(component.id, dropdownOptions);
}

/**
 * Create dialog from a component
 *
 * @param {HTMLElement} component - The component to be created
 * @return {void}
 */
const createDialog = (component) => {
  const {
    dataset: { dialog, ...attrs }
  } = component;

  // NOTE: due to some SR bugs we have to set the focus on the title
  // See discussion: https://github.com/decidim/decidim/issues/9760
  // See further info: https://adrianroselli.com/2020/10/dialog-focus-in-screen-readers.html
  const setFocusOnTitle = (content) => {
    const heading = content.querySelector("[id^=dialog-title]")
    if (heading) {
      heading.setAttribute("tabindex", heading.getAttribute("tabindex") || -1)
      heading.focus();
    }
  }

  const modal = new Dialogs(`[data-dialog="${dialog}"]`, {
    openingSelector: `[data-dialog-open="${dialog}"]`,
    closingSelector: `[data-dialog-close="${dialog}"]`,
    backdropSelector: `[data-dialog="${dialog}"]`,
    enableAutoFocus: false,
    onOpen: (params, trigger) => {
      setFocusOnTitle(params);
      window.focusGuard.trap(params, trigger);
      params.dispatchEvent(new CustomEvent("open.dialog"));
    },
    onClose: (params) => {
      window.focusGuard.disable();
      params.dispatchEvent(new CustomEvent("close.dialog"));
    },
    // optional parameters (whenever exists the id, it will add the tagging)
    ...(Boolean(component.querySelector(`#dialog-title-${dialog}`)) && {
      labelledby: `dialog-title-${dialog}`
    }),
    ...(Boolean(component.querySelector(`#dialog-desc-${dialog}`)) && {
      describedby: `dialog-desc-${dialog}`
    }),
    // Add any other options passed via data-attributes
    ...attrs
  });

  // attach all modals to the body, removing them from wherever are placed
  document.body.appendChild(modal.dialog)

  // in order to use the Dialog object somewhere else
  window.Decidim.currentDialogs = { ...window.Decidim.currentDialogs, [dialog]: modal }

  // NOTE: when a remote modal is open, the contents are empty
  // once they are in the DOM, we append the ARIA attributes
  // otherwise they could not exist yet
  // (this listener must be applied over 'document', not 'element')
  document.addEventListener("remote-modal:loaded", () => {
    const heading = modal.dialog.querySelector(`#dialog-title-${dialog}`)
    if (heading) {
      modal.dialog.setAttribute("aria-labelledby", `dialog-title-${dialog}`);
      setFocusOnTitle(modal.dialog)
    }
    if (modal.dialog.querySelector(`#dialog-desc-${dialog}`)) {
      modal.dialog.setAttribute("aria-describedby", `dialog-desc-${dialog}`);
    }
  })
}

/**
 * Announces a message to the screen reader dynamically.
 *
 * This should not be called consecutively multiple times because the screen
 * reader may not read all the messages if the content is changed quickly.
 *
 * @param {String} message The message to be announced
 * @param {String} mode The mode for the announcement, either "assertive"
 *   (default) or "polite".
 * @return {void}
 */
const announceForScreenReader = (message, mode = "assertive") => {
  if (!message || typeof message !== "string" || message.length < 1) {
    return;
  }

  let element = document.getElementById("screen-reader-announcement");
  if (!element) {
    element = document.createElement("div");
    element.setAttribute("id", "screen-reader-announcement");
    element.classList.add("sr-only");
    element.setAttribute("aria-atomic", true);
    document.body.append(element);
  }
  if (mode === "polite") {
    element.setAttribute("aria-live", mode);
  } else {
    element.setAttribute("aria-live", "assertive");
  }

  element.innerHTML = "";

  setTimeout(() => {
    // Wrap the text in a span with a random attribute value that changes every
    // time to try to indicate to the screen reader the content has changed. This
    // helps reading the message aloud if the message is exactly the same as the
    // last time.
    const randomIdentifier = `announcement-${new Date().getUTCMilliseconds()}-${Math.floor(Math.random() * 10000000)}`;
    const announce = document.createElement("span")
    announce.setAttribute("data-random", randomIdentifier);
    announce.textContent = message;
    element.append(announce);
  }, 100);
};

export {
  createAccordion,
  createDialog,
  createDropdown,
  announceForScreenReader,
  Accordions,
  Dialogs,
  Dropdowns
}
