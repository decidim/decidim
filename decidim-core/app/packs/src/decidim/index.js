/**
 * External dependencies
 */

// external deps with no initialization
import "core-js/stable";
import "regenerator-runtime/runtime";
import "jquery"

// REDESIGN_PENDING: deprecated
import "foundation-sites";

// external deps that require initialization
import Rails from "@rails/ujs"
import svg4everybody from "svg4everybody"
import morphdom from "morphdom"

/**
 * Local dependencies
 */
import updateExternalDomainLinks from "src/decidim/refactor/implementation/external_domain_warning"
import ExternalLink from "src/decidim/refactor/implementation/external_link"
import Configuration from "src/decidim/refactor/implementation/configuration"
import setOnboardingAction from "src/decidim/refactor/integration/onboarding_pending_action"

// local deps with no initialization
import "src/decidim/refactor/moved/history"
import "src/decidim/append_redirect_url_to_modals"
import "src/decidim/form_attachments"
import "src/decidim/form_remote"
import "src/decidim/refactor/moved/delayed"
import "src/decidim/security/selfxss_warning"
import "src/decidim/session_timeouter"
import "src/decidim/results_listing"
import "src/decidim/data_consent"
import "src/decidim/sw"
import "src/decidim/attachments"
import "src/decidim/callout"

// local deps that require initialization
import ConfirmDialog, { initializeConfirm } from "src/decidim/confirm"
import { initializeUploadFields } from "src/decidim/direct_uploads/upload_field"
import { initializeReverseGeocoding } from "src/decidim/geocoding/reverse_geocoding"
import FocusGuard from "src/decidim/refactor/moved/focus_guard"
import markAsReadNotifications from "src/decidim/notifications"
import RemoteModal from "src/decidim/remote_modal"
import {
  createDialog,
  announceForScreenReader,
  Dialogs
} from "src/decidim/a11y"

// bad practice: window namespace should avoid be populated as much as possible
// rails-translations could be referenced through a single Decidim.I18n object
window.Decidim = window.Decidim || {
  config: new Configuration(),
  ExternalLink,
  Dialogs,
  ConfirmDialog,
  announceForScreenReader
};

window.morphdom = morphdom

// eslint-disable-next-line max-params
const deprecate = (element, targetController, oldSyntax) => {
  if (element.hasAttribute("data-controller") && element.getAttribute("data-controller").includes(targetController)) {
    return;
  }

  console.warn(`[Decidim] ${oldSyntax} is deprecated. Please use the new version of this component - data-controller="${targetController}" - ${window.location.href}`)

  if (typeof window.Decidim.dev !== "undefined" && window.Decidim.dev === true) {
    // eslint-disable-next-line no-alert
    alert(`[Decidim] ${oldSyntax} is deprecated. Please use the new version of this component - data-controller="${targetController}"`)
  }
}

const deprecationMessage = (element, oldSyntax, newSyntax) => {
  console.warn(`[Decidim] ${oldSyntax} is deprecated. Please use the new version of this component - ${newSyntax}`)

  if (typeof window.Decidim.dev !== "undefined" && window.Decidim.dev === true) {
    // eslint-disable-next-line no-alert
    alert(`[Decidim] ${oldSyntax} is deprecated. Please use the new version of this component - ${newSyntax}`)
  }
}

window.deprecate = deprecate;
window.deprecationMessage = deprecationMessage;

document.addEventListener("turbo:load", () => {
  document.querySelectorAll("[data-tabs]").forEach((elem) =>
    deprecate(elem, "tabs", "[data-tabs]"))
  document.querySelectorAll("[data-sticky-buttons]").forEach((container) =>
    deprecate(container, "sticky-buttons", "[data-sticky-buttons]"));
  document.querySelectorAll("[data-clipboard-copy]").forEach((container) =>
    deprecate(container, "clipboard", "[data-clipboard-copy]"));
  document.querySelectorAll('[data-component="accordion"]').forEach((container) =>
    deprecate(container, "accordion", "data-component='accordion'"));
  document.querySelectorAll('[data-component="dropdown"]').forEach((container) =>
    deprecate(container, "dropdown", "data-component='dropdown'"));
  document.querySelectorAll("[data-scroll-last-child]").forEach((container) =>
    deprecate(container, "scroll-to-last", "data-scroll-last-child"));
  document.querySelectorAll(".editor-container").forEach((container) =>
    deprecate(container, "editor", ".editor-container"));
  document.querySelectorAll(".new_report").forEach((container) =>
    deprecate(container, "report-form", ".new_report"));
  document.querySelectorAll(".user-password").forEach((container) =>
    deprecate(container, "password-toggler", ".user-password"));
  document.querySelectorAll(".api-user-secret").forEach((container) =>
    deprecate(container, "password-toggler", ".api-user-secret"));
  document.querySelectorAll("[data-input-emoji]").forEach((container) =>
    deprecate(container, "emoji", "[data-input-emoji]"));
  document.querySelectorAll(".js-mentions").forEach((container) =>
    deprecate(container, "mention", ".js-mentions"));
  document.querySelectorAll(".js-multiple-mentions").forEach((container) =>
    deprecate(container, "multiple-mentions", ".js-multiple-mentions"))
  document.querySelectorAll("[data-tooltip]").forEach((elem) =>
    deprecate(elem, "tooltip", "[data-tooltip]"))
  document.querySelectorAll(".delete-account").forEach((container) =>
    deprecate(container, "delete-account-form", ".delete-account"))
  document.querySelectorAll("[data-notification-action]").forEach((elem) =>
    deprecate(elem, "notification-action", "[data-notification-action]"))
  document.querySelectorAll("#register-from").forEach((elem) =>
    deprecate(elem, "user-registration-form", "#register-from"))
  document.querySelectorAll("#omniauth-register-from").forEach((elem) =>
    deprecate(elem, "user-registration-form", "#omniauth-register-from"))
  document.querySelectorAll(".js-tags-container").forEach((container) =>
    deprecate(container, "input-tags", ".js-tags-container"))
  document.querySelectorAll("[data-toggle]").forEach((elem) =>
    deprecate(elem, "toggle", "[data-toggle]"))
  document.querySelectorAll("[data-impersonation-warning]").forEach((container) =>
    deprecate(container, "impersonation-warning", "[data-impersonation-warning]"))
  document.querySelectorAll("#panel-password.user-password").forEach((container) =>
    deprecate(container, "account-form", "#panel-password"))
  document.querySelectorAll(".slug").forEach((container) =>
    deprecate(container, ".slug", "slug"))
  document.querySelectorAll("textarea[maxlength], textarea[minlength]").forEach((container) =>
    deprecate(container, "character-counter", "textarea[maxlength], textarea[minlength]"))
  document.querySelectorAll("input[type='text'][maxlength], input[type='text'][minlength]").forEach((container) =>
    deprecate(container, "character-counter", "input[type='text'][maxlength], input[type='text'][minlength]"))
  document.querySelectorAll(".editor>input[type='hidden'][maxlength], .editor>input[type='hidden'][minlength]").forEach((container) =>
    deprecate(container, "character-counter", ".editor>input[type='hidden'][maxlength], .editor>input[type='hidden'][minlength]"))

  document.querySelectorAll('input[type="datetime-local"]').forEach((container) =>
    deprecate(container, "date-picker", 'input[type="datetime-local"]'));
  document.querySelectorAll('input[type="date"]').forEach((container) =>
    deprecate(container, "date-picker", 'input[type="date"]'));

  document.querySelectorAll("form.new_filter").forEach((container) =>
    deprecate(container, "form-filter", "form.new_filter"))

  document.querySelectorAll(".responsive-tab-block").forEach((container) =>
    deprecationMessage(container, ".responsive-tab-block", "NEEDS TO BE REMOVED"));
  document.querySelectorAll('.callout[role="alert"]').forEach((container) =>
    deprecationMessage(container, '.callout[role="alert"]', '.flash[role="alert"]'));
  document.querySelectorAll(".js-back-to-list").forEach((container) =>
    deprecationMessage(container, ".js-back-to-list", "NEEDS TO BE REMOVED"));
  document.querySelectorAll("[data-toggler]").forEach((container) =>
    deprecationMessage(container, "[data-toggler]", "Use the Stimulus toggle controller with hidden targets"));
})

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

  element.querySelectorAll("a[target=\"_blank\"]:not([data-external-link=\"false\"])").forEach((elem) => {
    // both functions (updateExternalDomainLinks and ExternalLink) are related, so if we disable one, the other also
    updateExternalDomainLinks(elem)

    return new ExternalLink(elem)
  })

  markAsReadNotifications(element)

  element.querySelectorAll("[data-dialog]").forEach((component) => createDialog(component))

  // Initialize available remote modals (ajax-fetched contents)
  element.querySelectorAll("[data-dialog-remote-url]").forEach((elem) => new RemoteModal(elem))

  // https://github.com/tremend-cofe/decidim-js/pull/6
  element.querySelectorAll("[data-controller='onboarding']").forEach((elem) => setOnboardingAction(elem));
  element.querySelectorAll("[data-onboarding-action]").forEach((elem) => {
    console.error(`${window.location.href} Using data-onboarding-action. Please switch to data-controller="onboarding" data-onboarding-action-value="$action".`);
    setOnboardingAction(elem);
  })

  initializeUploadFields(element.querySelectorAll("button[data-upload]"));
  initializeReverseGeocoding()

  element.querySelectorAll("[data-controller='accordion']").forEach((accordion) => {
    accordion.dispatchEvent(new CustomEvent("accordion:reconnect", { detail: { collapse: true } }));
  });

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

