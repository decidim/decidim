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
  dropdownOptions.isOpen = component.dataset.open === "true";
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
      window.focusGuard.trap(trigger);
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

export {
  createAccordion,
  createDialog,
  createDropdown,
  Accordions,
  Dialogs,
  Dropdowns
}
