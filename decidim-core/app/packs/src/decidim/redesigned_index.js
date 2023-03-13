/**
 * External dependencies
 */

// external deps with no initialization
import "core-js/stable";
import "regenerator-runtime/runtime";
import "jquery"
import "quill"

// external deps that require initialization
import Rails from "@rails/ujs"
import svg4everybody from "svg4everybody"
import morphdom from "morphdom"
import Accordions from "a11y-accordion-component";
import Dropdowns from "a11y-dropdown-component";
import Dialogs from "a11y-dialog-component";

// vendor customizated scripts (bad practice: these ones should be removed eventually)
import "./vendor/foundation-datepicker"
import "./foundation_datepicker_locales"
import "./vendor/modernizr"

/**
 * Local dependencies
 */

// local deps with no initialization
import "./input_tags"
import "./input_hashtags"
import "./input_mentions"
import "./input_multiple_mentions"
import "./input_autojump"
import "./history"
import "./callout"
import "./clipboard"
import "./append_elements"
import "./user_registrations"
import "./account_form"
// import "./dropdowns_menus" -- deprecated
import "./append_redirect_url_to_modals"
import "./form_attachments"
import "./form_remote"
// import "./conferences" -- deprecated
// import "./tooltip_keep_on_hover" -- deprecated
// import "./diff_mode_dropdown" -- deprecated
import "./delayed"
import "./vizzs"
import "./responsive_horizontal_tabs"
import "./security/selfxss_warning"
// import "./floating_help" --deprecated
import "./redesigned_session_timeouter"
import "./confirm"
import "./results_listing"
// import "./represent_user_group" -- deprecated
import "./impersonation"
// import "./start_conversation_dialog" -- deprecated
import "./gallery"
import "./direct_uploads/redesigned_upload_field"
import "./data_consent"

// local deps that require initialization
import formDatePicker from "./form_datepicker"
import fixDropdownMenus from "./dropdowns_menus"
import createQuillEditor from "./editor"
import Configuration from "./configuration"
import ExternalLink from "./redesigned_external_link"
import updateExternalDomainLinks from "./external_domain_warning"
import scrollToLastChild from "./scroll_to_last_child"
import InputCharacterCounter, { createCharacterCounter } from "./redesigned_input_character_counter"
import FormValidator from "./form_validator"
import DataPicker from "./data_picker"
import FormFilterComponent from "./redesigned_form_filter"
import addInputEmoji, { EmojiButton } from "./input_emoji"
import dialogMode from "./dialog_mode"
import FocusGuard from "./focus_guard"
import backToListLink from "./back_to_list"
import markAsReadNotifications from "./notifications"
import RemoteModal from "./redesigned_ajax_modals"
import selectActiveIdentity from "./redesigned_identity_selector_dialog"
import createTooltip from "./redesigned_tooltips"
import viewMore from "./view_more"

// bad practice: window namespace should avoid be populated as much as possible
// rails-translations could be referrenced through a single Decidim.I18n object
window.Decidim = window.Decidim || {
  config: new Configuration(),
  ExternalLink,
  InputCharacterCounter,
  FormValidator,
  DataPicker,
  addInputEmoji,
  EmojiButton,
  Accordions,
  Dropdowns,
  Dialogs
};

window.morphdom = morphdom

Rails.start()

/**
 * Initializer event for those script who require to be triggered
 * when the page is loaded
 *
 * @param {HTMLElement} element target node
 * @returns {void}
 */
const initializer = (element = document) => {
  window.theDataPicker = new DataPicker($(".data-picker"));
  window.focusGuard = new FocusGuard(element.querySelector("body"));

  $(element).foundation();
  $(element).on("open.zf.reveal", (ev) => {
    dialogMode($(ev.target));
  });

  // Trap the focus within the mobile menu if the user enters it. This is an
  // accessibility feature forcing the focus within the offcanvas container
  // which holds the mobile menu.
  $("#offCanvas").on("openedEnd.zf.offCanvas", (ev) => {
    ev.target.querySelector(".main-nav a").focus();
    window.focusGuard.trap(ev.target);
  }).on("closed.zf.offCanvas", () => {
    window.focusGuard.disable();
  });

  fixDropdownMenus();

  svg4everybody();

  // Prevent data-open buttons e.g. from submitting the underlying form in
  // authorized action buttons.
  $("[data-open]").on("click", (event) => {
    event.preventDefault();
  });

  formDatePicker();

  $(".editor-container").each((_idx, container) => {
    createQuillEditor(container);
  });

  element.querySelectorAll("a[target=\"_blank\"]:not([data-external-link=\"false\"])").forEach((elem) => new ExternalLink(elem))

  // initialize character counter
  $("input[type='text'], textarea, .editor>input[type='hidden']").each((_i, elem) => {
    const $input = $(elem);

    if (!$input.is("[minlength]") && !$input.is("[maxlength]")) {
      return;
    }

    createCharacterCounter($input);
  });

  $("form.new_filter").each(function () {
    // eslint-disable-next-line no-invalid-this
    const formFilter = new FormFilterComponent($(this));

    formFilter.mountComponent();
  })

  updateExternalDomainLinks($("body"))

  addInputEmoji(element)

  backToListLink(element.querySelectorAll(".js-back-to-list"));

  markAsReadNotifications()

  scrollToLastChild()

  viewMore()

  // https://github.com/jonathanlevaillant/a11y-accordion-component
  Accordions.init();
  // https://github.com/jonathanlevaillant/a11y-dropdown-component
  Dropdowns.init();
  // https://github.com/jonathanlevaillant/a11y-dialog-component
  element.querySelectorAll("[data-dialog]").forEach((elem) => {
    const {
      dataset: { dialog }
    } = elem;

    // NOTE: due to some SR bugs we've to set the focus on the title
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
      // optional parameters (whenever exists the id, it'll add the tagging)
      ...(Boolean(elem.querySelector(`#dialog-title-${dialog}`)) && {
        labelledby: `dialog-title-${dialog}`
      }),
      ...(Boolean(elem.querySelector(`#dialog-desc-${dialog}`)) && {
        describedby: `dialog-desc-${dialog}`
      })
    });

    // in order to use the Dialog object somewhere else
    window.Decidim.currentDialogs = { ...window.Decidim.currentDialogs, [dialog]: modal }

    // NOTE: when a remote modal is open, the contents are empty
    // once they're in the DOM, we append the ARIA attributes
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
  });

  // Initialize available remote modals (ajax-fetched contents)
  element.querySelectorAll("[data-dialog-remote-url]").forEach((elem) => new RemoteModal(elem))

  // Add event listeners to identity modal
  element.querySelectorAll("[data-user-identity]").forEach((elem) => selectActiveIdentity(elem))

  // Initialize data-tooltips
  element.querySelectorAll("[data-tooltip]").forEach((elem) => createTooltip(elem))
}

// If no jQuery is used the Tribute feature used in comments to autocomplete
// mentions stops working
// document.addEventListener("DOMContentLoaded", () => {
$(() => initializer());

// Run initializer action over the new DOM elements
document.addEventListener("remote-modal:loaded", ({ detail }) => initializer(detail));
