/* eslint-disable max-lines */

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
import "./sw"

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
import createToggle from "./redesigned_toggle"
import {
  createAccordion,
  createDialog,
  createDropdown,
  Dialogs
} from "./redesigned_a11y"

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

  let focusContainer = element;
  if (element === document) {
    focusContainer = document.querySelector("body");
  }
  window.focusGuard = new FocusGuard(focusContainer);

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

  // https://github.com/jonathanlevaillant/a11y-accordion-component
  element.querySelectorAll('[data-component="accordion"]').forEach((component) => createAccordion(component))

  // https://github.com/jonathanlevaillant/a11y-dropdown-component
  element.querySelectorAll('[data-component="dropdown"]').forEach((component) => createDropdown(component))

  // https://github.com/jonathanlevaillant/a11y-dialog-component
  element.querySelectorAll("[data-dialog]").forEach((component) => createDialog(component))

  // Initialize available remote modals (ajax-fetched contents)
  element.querySelectorAll("[data-dialog-remote-url]").forEach((elem) => new RemoteModal(elem))

  // Add event listeners to identity modal
  element.querySelectorAll("[data-user-identity]").forEach((elem) => selectActiveIdentity(elem))

  // Initialize data-tooltips
  element.querySelectorAll("[data-tooltip]").forEach((elem) => createTooltip(elem))

  // Initialize data-toggles
  element.querySelectorAll("[data-toggle]").forEach((elem) => createToggle(elem))
}

// If no jQuery is used the Tribute feature used in comments to autocomplete
// mentions stops working
// document.addEventListener("DOMContentLoaded", () => {
$(() => initializer());

// Run initializer action over the new DOM elements
document.addEventListener("remote-modal:loaded", ({ detail }) => initializer(detail));
document.addEventListener("ajax:loaded", ({ detail }) => initializer(detail));

// Run initializer action over the new DOM elements (for example after comments polling)
document.addEventListener("comments:loaded", (event) => {
  const commentsIds = event.detail.commentsIds;
  if (commentsIds) {
    commentsIds.forEach((commentId) => {
      const commentsContainer = document.getElementById(`comment_${commentId}`);
      if (commentsContainer) {
        initializer(commentsContainer)
      }
    });
  }
});
