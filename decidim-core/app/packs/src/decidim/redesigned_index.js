/**
 * External dependencies
 */

// external deps with no initialization
import "core-js/stable";
import "regenerator-runtime/runtime";
import "jquery"
import "quill"
import Rails from "@rails/ujs"

// external deps that require initialization
import svg4everybody from "svg4everybody"
import morphdom from "morphdom"
import Accordions from "a11y-accordion-component";
import Dropdowns from "a11y-dropdown-component";
import Dialogs from "a11y-dialog-component";
import { StreamActions } from "@hotwired/turbo"
import { Turbo } from "@hotwired/turbo-rails"

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
import "./conferences"
import "./tooltip_keep_on_hover"
// import "./diff_mode_dropdown" -- deprecated
import "./delayed"
import "./vizzs"
import "./responsive_horizontal_tabs"
import "./security/selfxss_warning"
import "./session_timeouter"
import "./floating_help"
import "./confirm"
import "./results_listing"
// import "./represent_user_group" -- deprecated
import "./impersonation"
// import "./start_conversation_dialog" -- deprecated
import "./identity_selector_dialog"
import "./gallery"
import "./direct_uploads/redesigned_upload_field"

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
import RemoteModal from "./ajax_modals"
import setHeadingTag from "./redesigned_heading_tag"

// bad practice: window namespace should avoid be populated as much as possible
// rails-translations could be referrenced through a single Decidim.I18n object
window.Decidim = window.Decidim || {
  config: new Configuration(),
  ExternalLink,
  InputCharacterCounter,
  FormValidator,
  DataPicker,
  addInputEmoji,
  EmojiButton
};

window.morphdom = morphdom

Rails.start()

/**
 * Initializer event for those script who require to be triggered
 * when the page is loaded
 *
 * @returns {void}
 */
const initializer = () => {
  window.theDataPicker = new DataPicker($(".data-picker"));
  window.focusGuard = new FocusGuard(document.querySelector("body"));

  $(document).foundation();
  $(document).on("open.zf.reveal", (ev) => {
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

  // initialize external-link feature only to the matching elements
  document.querySelectorAll("a[target=\"_blank\"]:not([data-external-link=\"false\"])").forEach((elem) => new ExternalLink(elem))

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

  addInputEmoji()

  backToListLink(document.querySelectorAll(".js-back-to-list"));

  Accordions.init();
  Dropdowns.init();
  document.querySelectorAll("[data-dialog]").forEach((elem) => {
    const {
      dataset: { dialog }
    } = elem;
    return new Dialogs(`[data-dialog="${dialog}"]`, {
      openingSelector: `[data-dialog-open="${dialog}"]`,
      closingSelector: `[data-dialog-close="${dialog}"]`,
      // optional parameters (whenever exists the id, it'll add the tagging)
      ...(Boolean(elem.querySelector(`#dialog-title-${dialog}`)) && {
        labelledby: `dialog-title-${dialog}`
      }),
      ...(Boolean(elem.querySelector(`#dialog-desc-${dialog}`)) && {
        describedby: `dialog-desc-${dialog}`
      })
    });
  });

  // Initialize available remote modals (ajax-fetched contents)
  document.querySelectorAll("[data-dialog-remote-url]").forEach((elem) => new RemoteModal(elem))

  document.querySelectorAll("[data-drawer]").forEach(
    ({ dataset: { drawer } }) =>
      new Dialogs(`[data-drawer="${drawer}"]`, {
        openingSelector: `[data-drawer-open="${drawer}"]`,
        closingSelector: `[data-drawer-close="${drawer}"]`
      })
  );

  markAsReadNotifications()

  scrollToLastChild()

  document.
    querySelectorAll("[data-drawer]").
    forEach(({ dataset: { drawer } }) =>
      new Dialogs(`[data-drawer="${drawer}"]`, {
        closingSelector: `[data-drawer-close="${drawer}"]`,
        onOpen: (node) => setHeadingTag(node),
        onClose: (node) => {
          setHeadingTag(node);
          Turbo.navigator.history.replace({ href: drawer });
        }
      }).open()
    );
}

if ("Turbo" in window) {
  document.addEventListener("turbo:frame-render", () => initializer());
  document.addEventListener("turbo:load", () => initializer());
} else {
  // If no jQuery is used the Tribute feature used in comments to autocomplete
  // mentions stops working
  // document.addEventListener("DOMContentLoaded", () => {
  $(() => initializer());
}

// eslint-disable-next-line camelcase
StreamActions.open_drawer = function() {
  const frameId = this.getAttribute("frame_id");
  const drawerItem = document.getElementById(frameId);
  const filteredPath = drawerItem.dataset.filteredPath;

  if (filteredPath) {
    drawerItem.querySelector("a[data-drawer-close]").setAttribute("href", filteredPath);
    drawerItem.querySelector("div[data-drawer]").setAttribute("data-drawer", filteredPath);
  }
}
