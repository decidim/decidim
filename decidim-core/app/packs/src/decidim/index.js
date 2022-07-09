/* eslint-disable no-invalid-this */

import svg4everybody from "svg4everybody"
import formDatePicker from "src/decidim/form_datepicker"
import fixDropdownMenus from "src/decidim/dropdowns_menus"
import createQuillEditor from "src/decidim/editor"
import Configuration from "src/decidim/configuration"
import ExternalLink from "src/decidim/redesigned_external_link"
import updateExternalDomainLinks from "src/decidim/external_domain_warning"
import InputCharacterCounter from "src/decidim/input_character_counter"
import FormValidator from "src/decidim/form_validator"
import CommentsComponent from "src/decidim/comments/comments.component"
import DataPicker from "src/decidim/data_picker"
import FormFilterComponent from "src/decidim/form_filter"
import addInputEmoji from "src/decidim/input_emoji"
import dialogMode from "src/decidim/dialog_mode"
import FocusGuard from "src/decidim/focus_guard"
import backToListLink from "src/decidim/back_to_list"

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()
window.Decidim.ExternalLink = ExternalLink;
window.Decidim.InputCharacterCounter = InputCharacterCounter;
window.Decidim.FormValidator = FormValidator;
window.Decidim.DataPicker = DataPicker;
window.Decidim.CommentsComponent = CommentsComponent;
window.Decidim.addInputEmoji = addInputEmoji;

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

  document.querySelectorAll("a[target=\"_blank\"]:not([no-external-link])").forEach((elem) => new ExternalLink(elem))

  // Mount comments component
  $("[data-decidim-comments]").each((_i, el) => {
    const $el = $(el);
    const comments = new CommentsComponent($el, $el.data("decidim-comments"));
    comments.mountComponent();
    $(el).data("comments", comments);
  });

  $("form.new_filter").each(function () {
    const formFilter = new FormFilterComponent($(this));

    formFilter.mountComponent();
  })

  updateExternalDomainLinks($("body"))

  addInputEmoji()

  backToListLink(document.querySelectorAll(".js-back-to-list"));
});
