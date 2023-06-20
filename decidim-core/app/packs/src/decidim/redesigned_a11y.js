import Accordions from "a11y-accordion-component";
import Dropdowns from "a11y-dropdown-component";
import Dialogs from "a11y-dialog-component";
import { screens } from "tailwindcss/defaultTheme"

const createAccordion = (component) => {
  const accordionOptions = {};
  accordionOptions.isMultiSelectable = component.dataset.multiselectable !== "false";
  accordionOptions.isCollapsible = component.dataset.collapsible !== "false";

  // This snippet allows to change a data-attribute based on the current viewport
  // Just include the breakpoint where the different value will be applied from.
  // Ex:
  // data-open="false" data-open-md="true"
  Object.keys(screens).forEach((key) => (window.matchMedia(`(min-width: ${screens[key]})`).matches) && component.querySelectorAll(`[data-controls][data-open-${key}]`).forEach((elem) => (elem.dataset.open = elem.dataset[`open-${key}`.replace(/-([a-z])/g, (str) => str[1].toUpperCase())])))

  if (!component.id) {
    // when component has no id, we enforce to have it one
    component.id = `accordion-${Math.random().toString(36).substring(7)}`
  }

  Accordions.render(component.id, accordionOptions);
}

const createDropdown = (component) => {
  const dropdownOptions = {};
  dropdownOptions.dropdown = component.dataset.target;
  dropdownOptions.hover = component.dataset.hover === "true";
  dropdownOptions.isOpen = component.dataset.open === "true";
  dropdownOptions.autoClose = component.dataset.autoClose === "true";

  if (!component.id) {
    // when component has no id, we enforce to have it one
    component.id = `dropdown-${Math.random().toString(36).substring(7)}`
  }

  Dropdowns.render(component.id, dropdownOptions);
}

const createDialog = (component) => {
  const {
    dataset: { dialog }
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
    onOpen: (params) => {
      setFocusOnTitle(params)
    },
    // optional parameters (whenever exists the id, it will add the tagging)
    ...(Boolean(component.querySelector(`#dialog-title-${dialog}`)) && {
      labelledby: `dialog-title-${dialog}`
    }),
    ...(Boolean(component.querySelector(`#dialog-desc-${dialog}`)) && {
      describedby: `dialog-desc-${dialog}`
    })
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
