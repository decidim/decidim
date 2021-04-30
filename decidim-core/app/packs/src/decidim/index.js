/* eslint-disable no-invalid-this */

import svg4everybody from "svg4everybody"
import formDatePicker from "./form_datepicker"
import fixDropdownMenus from "./dropdowns_menus"
import createQuillEditor from "./editor"
import Configuration from "./configuration"
import ExternalLink from "./external_link"
import updateExternalDomainLinks from "./external_domain_warning"
import InputCharacterCounter from "./input_character_counter"
import FormValidator from "./form_validator"
import CommentsComponent from "../../../../../decidim-comments/app/packs/src/decidim/comments/comments.component"
import DataPicker from "./data_picker"
import FormFilterComponent from "./form_filter"

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()
window.Decidim.ExternalLink = ExternalLink;
window.Decidim.InputCharacterCounter = InputCharacterCounter;
window.Decidim.FormValidator = FormValidator;
window.Decidim.DataPicker = DataPicker;
window.Decidim.CommentsComponent = CommentsComponent;

$(() => {
  window.theDataPicker = new DataPicker($(".data-picker"));

  $(document).foundation();

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
});
