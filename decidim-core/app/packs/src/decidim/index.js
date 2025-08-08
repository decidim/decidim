/**
 * External dependencies
 */

// external deps with no initialization
import "core-js/stable";
import "regenerator-runtime/runtime";
import "jquery"
import "chartkick/chart.js"

// REDESIGN_PENDING: deprecated
import "foundation-sites";

// external deps that require initialization
import Rails from "@rails/ujs"
import svg4everybody from "svg4everybody"
import morphdom from "morphdom"

/**
 * Local dependencies
 */
import PasswordToggler from "src/decidim/password_toggler";
import UserRegistrationForm from "src/decidim/refactor/integration/user_registration_form";
import MentionsComponent from "src/decidim/refactor/implementation/input_mentions";
import FormValidator from "src/decidim/refactor/implementation/form_validator"
import updateExternalDomainLinks from "src/decidim/refactor/implementation/external_domain_warning"
import ClipboardCopy from "src/decidim/refactor/implementation/copy_clipboard";
import ExternalLink from "src/decidim/refactor/implementation/external_link"
import Configuration from "src/decidim/refactor/implementation/configuration"
import MultipleMentionsManager from "src/decidim/refactor/implementation/input_multiple_mentions";
import setOnboardingAction from "src/decidim/refactor/integration/onboarding_pending_action"

// local deps with no initialization
import "src/decidim/input_tags"
import "src/decidim/history"
import "src/decidim/callout"
import "src/decidim/account_form"
import "src/decidim/append_redirect_url_to_modals"
import "src/decidim/form_attachments"
import "src/decidim/form_remote"
import "src/decidim/delayed"
import "src/decidim/responsive_horizontal_tabs"
import "src/decidim/security/selfxss_warning"
import "src/decidim/session_timeouter"
import "src/decidim/results_listing"
import "src/decidim/impersonation"
import "src/decidim/gallery"
import "src/decidim/data_consent"
import "src/decidim/sw"
import "src/decidim/sticky_header"
import "src/decidim/sticky_footer"
import "src/decidim/attachments"
import "src/decidim/dropdown_menu"

// local deps that require initialization
import ConfirmDialog, { initializeConfirm } from "src/decidim/confirm"
import { initializeUploadFields } from "src/decidim/direct_uploads/upload_field"
import { initializeReverseGeocoding } from "src/decidim/geocoding/reverse_geocoding"
import formDatePicker from "src/decidim/datepicker/form_datepicker"
import scrollToLastChild from "src/decidim/scroll_to_last_child"
import InputCharacterCounter, { createCharacterCounter } from "src/decidim/input_character_counter"
import FormFilterComponent from "src/decidim/form_filter"
import addInputEmoji, { EmojiButton } from "src/decidim/input_emoji"
import FocusGuard from "src/decidim/focus_guard"
import backToListLink from "src/decidim/back_to_list"
import markAsReadNotifications from "src/decidim/notifications"
import handleNotificationActions from "src/decidim/notifications_actions"
import RemoteModal from "src/decidim/remote_modal"
import createTooltip from "src/decidim/tooltips"
import createToggle from "src/decidim/toggle"
import {
  createAccordion,
  createDialog,
  createDropdown,
  announceForScreenReader,
  Dialogs
} from "src/decidim/a11y"
import changeReportFormBehavior from "src/decidim/change_report_form_behavior"

// bad practice: window namespace should avoid be populated as much as possible
// rails-translations could be referenced through a single Decidim.I18n object
window.Decidim = window.Decidim || {
  config: new Configuration(),
  ExternalLink,
  InputCharacterCounter,
  FormValidator,
  addInputEmoji,
  EmojiButton,
  Dialogs,
  ConfirmDialog,
  announceForScreenReader
};

window.morphdom = morphdom

// REDESIGN_PENDING: deprecated
window.initFoundation = (element) => {
  $(element).foundation();

  // Fix compatibility issue with the `a11y-accordion-component` package that
  // uses the `data-open` attribute to indicate the open state for the accordion
  // trigger.
  //
  // In Foundation, these listeners are initiated on the document node always,
  // regardless of the element for which foundation is initiated. Therefore, we
  // need the document node here instead of the `element` passed to this
  // function.
  const $document = $(document);

  $document.off("click.zf.trigger", window.Foundation.Triggers.Listeners.Basic.openListener);
  $document.on("click.zf.trigger", "[data-open]", (ev, ...restArgs) => {
    // Do not apply for the accordion triggers.
    const accordion = ev.currentTarget?.closest("[data-controller='accordion']");
    if (accordion) {
      return;
    }

    // Otherwise call the original implementation
    Reflect.apply(window.Foundation.Triggers.Listeners.Basic.openListener, ev.currentTarget, [ev, ...restArgs]);
  });
};

// Confirm initialization needs to happen before Rails.start()
initializeConfirm();
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
  window.initFoundation(element);

  svg4everybody();

  element.querySelectorAll('input[type="datetime-local"],input[type="date"]').forEach((elem) => formDatePicker(elem))

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
  handleNotificationActions(element)

  scrollToLastChild(element)

  element.querySelectorAll('[data-controller="accordion"]').forEach((component) => createAccordion(component))
  element.querySelectorAll('[data-component="accordion"]').forEach((component) => {
    if (component.hasAttribute("data-controller"))
    {
      return;
    }
    console.error(`${window.location.href} Using accordion component`);
    createAccordion(component);
  })

  element.querySelectorAll('[data-controller="dropdown"]').forEach((component) => createDropdown(component))
  element.querySelectorAll('[data-component="dropdown"]').forEach((component) => {
    console.error(`${window.location.href} Using dropdown component`);
    createDropdown(component);
  })

  element.querySelectorAll("[data-dialog]").forEach((component) => createDialog(component))

  // Initialize available remote modals (ajax-fetched contents)
  element.querySelectorAll("[data-dialog-remote-url]").forEach((elem) => new RemoteModal(elem))

  // Initialize data-tooltips
  element.querySelectorAll("[data-tooltip]").forEach((elem) => createTooltip(elem))

  // Initialize data-toggles
  element.querySelectorAll("[data-toggle]").forEach((elem) => createToggle(elem))

  element.querySelectorAll(".new_report").forEach((elem) => changeReportFormBehavior(elem))

  // https://github.com/tremend-cofe/decidim-js/pull/6
  element.querySelectorAll("[data-controller='onboarding']").forEach((elem) => setOnboardingAction(elem));
  element.querySelectorAll("[data-onboarding-action]").forEach((elem) => {
    console.error(`${window.location.href} Using data-onboarding-action. Please switch to data-controller="onboarding" data-onboarding-action-value="$action".`);
    setOnboardingAction(elem);
  })

  initializeUploadFields(element.querySelectorAll("button[data-upload]"));
  initializeReverseGeocoding()

  document.dispatchEvent(new CustomEvent("decidim:loaded", { detail: { element } }));
}

// If no jQuery is used the Tribute feature used in comments to autocomplete
// mentions stops working
$(() => initializer());

// Run initializer action over the new DOM elements
document.addEventListener("remote-modal:loaded", ({ detail }) => initializer(detail));
document.addEventListener("ajax:loaded", ({ detail }) => initializer(detail));

window.addEventListener("DOMContentLoaded", () => {
  document.dispatchEvent(new CustomEvent("turbo:load", { detail: { document } }));
});

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

// Handle external library integration (like React)
document.addEventListener("attach-mentions-element", (event) => {
  const instance = new MentionsComponent(event.detail);
  instance.attachToElement(event.detail);
});

document.addEventListener("turbo:load", () => {

  document.querySelectorAll(".js-mentions").forEach((container) => {
    if (!container._mentionContainer) {
      container._mentionContainer = new MentionsComponent(container);
    }
  });

  document.querySelectorAll("[data-clipboard-copy]").forEach((element) => {
    // Only initialize if not already initialized (prevents duplicates)
    if (!element._clipboardCopy) {
      element._clipboardCopy = new ClipboardCopy(element);
    }
  });

  document.querySelectorAll(".js-multiple-mentions").forEach((fieldContainer) => {
    // Initialize the multiple mentions manager
    const mentionsManager = new MultipleMentionsManager(fieldContainer);

    // Set up the selection event handler outside the class
    mentionsManager.searchInput.addEventListener("selection", (event) => {
      const feedback = event.detail;
      const selection = feedback.selection;
      mentionsManager.handleSelection(selection);
    });
  });

  // Initialize new FormValidator for all forms
  document.querySelectorAll("form").forEach((formElement) => {
    if (!formElement.dataset.formValidator) {
      formElement._FormValidator = new FormValidator(formElement, {
        liveValidate: formElement.dataset.liveValidate === "true",
        validateOnBlur: formElement.dataset.validateOnBlur === "true"
      });
      formElement.dataset.formValidator = true;
    }
  });

  (new UserRegistrationForm("register-form")).initialize();
  (new UserRegistrationForm("omniauth-register-form")).initialize();

  const userPassword = document.querySelector(".user-password");
  // Initialize password toggler if password field exists
  if (userPassword) {
    new PasswordToggler(userPassword).init();
  }
});
