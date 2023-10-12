/* eslint-disable max-lines */

/**
 * External dependencies
 */

// external deps with no initialization
import "core-js/stable";
import "regenerator-runtime/runtime";
import "jquery"

// external deps that require initialization
import Rails from "@rails/ujs"
import svg4everybody from "svg4everybody"
import morphdom from "morphdom"

// vendor customizated scripts (bad practice: these ones should be removed eventually)
import "./vendor/modernizr"

/**
 * Local dependencies
 */

// local deps with no initialization
import "src/decidim/input_tags"
import "src/decidim/input_hashtags"
import "src/decidim/input_mentions"
import "src/decidim/input_multiple_mentions"
import "src/decidim/input_autojump"
import "src/decidim/history"
import "src/decidim/callout"
import "src/decidim/clipboard"
import "src/decidim/append_elements"
import "src/decidim/user_registrations"
import "src/decidim/account_form"
import "src/decidim/append_redirect_url_to_modals"
import "src/decidim/form_attachments"
import "src/decidim/form_remote"
import "src/decidim/delayed"
import "src/decidim/vizzs"
import "src/decidim/responsive_horizontal_tabs"
import "src/decidim/security/selfxss_warning"
import "src/decidim/session_timeouter"
import "src/decidim/confirm"
import "src/decidim/results_listing"
import "src/decidim/impersonation"
import "src/decidim/gallery"
import "src/decidim/direct_uploads/upload_field"
import "src/decidim/data_consent"
import "src/decidim/sw"

// local deps that require initialization
import redesignedFormDatePicker from "./datepicker/form_datepicker"
import Configuration from "src/decidim/configuration"
import ExternalLink from "src/decidim/external_link"
import updateExternalDomainLinks from "src/decidim/external_domain_warning"
import scrollToLastChild from "src/decidim/scroll_to_last_child"
import InputCharacterCounter, { createCharacterCounter } from "src/decidim/input_character_counter"
import FormValidator from "src/decidim/form_validator"
import FormFilterComponent from "src/decidim/form_filter"
import addInputEmoji, { EmojiButton } from "src/decidim/input_emoji"
import FocusGuard from "src/decidim/focus_guard"
import backToListLink from "src/decidim/back_to_list"
import markAsReadNotifications from "src/decidim/notifications"
import RemoteModal from "src/decidim/remote_modal"
import selectActiveIdentity from "src/decidim/identity_selector_dialog"
import createTooltip from "src/decidim/tooltips"
import createToggle from "src/decidim/toggle"
import {
  createAccordion,
  createDialog,
  createDropdown,
  Dialogs
} from "src/decidim/a11y"
import changeReportFormBehavior from "src/decidim/change_report_form_behavior"

// bad practice: window namespace should avoid be populated as much as possible
// rails-translations could be referrenced through a single Decidim.I18n object
window.Decidim = window.Decidim || {
  config: new Configuration(),
  ExternalLink,
  InputCharacterCounter,
  FormValidator,
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
  // focus guard must be initialized only once
  window.focusGuard = window.focusGuard || new FocusGuard(document.body);

  // REDESIGN_PENDING: deprecated
  $(element).foundation();

  svg4everybody();

  redesignedFormDatePicker();

  element.querySelectorAll(".editor-container").forEach((container) => window.createEditor(container));

  // initialize character counter
  $("input[type='text'], textarea, .editor>input[type='hidden']", element).each((_i, elem) => {
    const $input = $(elem);

    if (!$input.is("[minlength]") && !$input.is("[maxlength]")) {
      return;
    }

    createCharacterCounter($input);
  });

  $("form.new_filter", element).each(function () {
    // eslint-disable-next-line no-invalid-this
    const formFilter = new FormFilterComponent($(this));

    formFilter.mountComponent();
  })

  element.querySelectorAll("a[target=\"_blank\"]:not([data-external-link=\"false\"])").forEach((elem) => {
    // both functions (updateExternalDomainLinks and ExternalLink) are related, so if we disable one, the other also
    updateExternalDomainLinks(elem)

    return new ExternalLink(elem)
  })

  addInputEmoji(element)

  backToListLink(element.querySelectorAll(".js-back-to-list"));

  markAsReadNotifications(element)

  scrollToLastChild(element)

  element.querySelectorAll('[data-component="accordion"]').forEach((component) => createAccordion(component))

  element.querySelectorAll('[data-component="dropdown"]').forEach((component) => createDropdown(component))

  element.querySelectorAll("[data-dialog]").forEach((component) => createDialog(component))

  // Initialize available remote modals (ajax-fetched contents)
  element.querySelectorAll("[data-dialog-remote-url]").forEach((elem) => new RemoteModal(elem))

  // Add event listeners to identity modal
  element.querySelectorAll("[data-user-identity]").forEach((elem) => selectActiveIdentity(elem))

  // Initialize data-tooltips
  element.querySelectorAll("[data-tooltip]").forEach((elem) => createTooltip(elem))

  // Initialize data-toggles
  element.querySelectorAll("[data-toggle]").forEach((elem) => createToggle(elem))

  element.querySelectorAll(".new_report").forEach((elem) => changeReportFormBehavior(elem))
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
