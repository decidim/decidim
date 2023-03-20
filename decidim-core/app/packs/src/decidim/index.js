/* eslint-disable no-invalid-this */

import svg4everybody from "svg4everybody"
import formDatePicker from "src/decidim/form_datepicker"
import fixDropdownMenus from "src/decidim/dropdowns_menus"
import createQuillEditor from "src/decidim/editor"
import Configuration from "src/decidim/configuration"
import ExternalLink from "src/decidim/external_link"
import updateExternalDomainLinks from "src/decidim/external_domain_warning"
import scrollToLastChild from "src/decidim/scroll_to_last_child"
import InputCharacterCounter, { createCharacterCounter } from "src/decidim/input_character_counter"
import FormValidator from "src/decidim/form_validator"
import DataPicker from "src/decidim/data_picker"
import FormFilterComponent from "src/decidim/form_filter"
import addInputEmoji, { EmojiButton } from "src/decidim/input_emoji"
import dialogMode from "src/decidim/dialog_mode"
import FocusGuard from "src/decidim/focus_guard"
import backToListLink from "src/decidim/back_to_list"
import markAsReadNotifications from "src/decidim/notifications"
import changeReportFormBehavior from "src/decidim/change_report_form_behavior"

// NOTE: new libraries required to give functionality to redesigned views
import Accordions from "a11y-accordion-component";
import Dropdowns from "a11y-dropdown-component";
import Dialogs from "a11y-dialog-component";
import RemoteModal from "./redesigned_ajax_modals"
// end new libraries

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()
window.Decidim.ExternalLink = ExternalLink;
window.Decidim.InputCharacterCounter = InputCharacterCounter;
window.Decidim.FormValidator = FormValidator;
window.Decidim.DataPicker = DataPicker;
window.Decidim.addInputEmoji = addInputEmoji;
window.Decidim.EmojiButton = EmojiButton;

/**
 * Initializer event for those script who require to be triggered
 * when the page is loaded
 */
// If no jQuery is used the Tribute feature used in comments to autocomplete
// mentions stops working
// document.addEventListener("DOMContentLoaded", () => {
$(() => {

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

  $('a[target="_blank"]').each((_i, elem) => {
    const $link = $(elem);
    $link.data("external-link", new ExternalLink($link));
  });

  // initialize character counter
  $("input[type='text'], textarea, .editor>input[type='hidden']").each((_i, elem) => {
    const $input = $(elem);

    if (!$input.is("[minlength]") && !$input.is("[maxlength]")) {
      return;
    }

    createCharacterCounter($input);
  });

  $("form.new_filter").each(function () {
    const formFilter = new FormFilterComponent($(this));

    formFilter.mountComponent();
  })
  document.querySelectorAll(".new_report").forEach((container) => changeReportFormBehavior(container))

  updateExternalDomainLinks($("body"))

  addInputEmoji()

  backToListLink(document.querySelectorAll(".js-back-to-list"));

  markAsReadNotifications()

  scrollToLastChild()

  // NOTE: new libraries required to give functionality to redesigned views
  Accordions.init();
  Dropdowns.init();
  document.querySelectorAll("[data-dialog]").forEach(
    (elem) => {
      const { dataset: { dialog } } = elem
      return new Dialogs(`[data-dialog="${dialog}"]`, {
        openingSelector: `[data-dialog-open="${dialog}"]`,
        closingSelector: `[data-dialog-close="${dialog}"]`,
        // optional parameters (whenever exists the id, it will add the tagging)
        ...(Boolean(elem.querySelector(`#dialog-title-${dialog}`)) && { labelledby: `dialog-title-${dialog}` }),
        ...(Boolean(elem.querySelector(`#dialog-desc-${dialog}`)) && { describedby: `dialog-desc-${dialog}` })
      })
    }
  );
  document.querySelectorAll("[data-dialog-remote-url]").forEach((elem) => new RemoteModal(elem))
  // end new libraries
});
