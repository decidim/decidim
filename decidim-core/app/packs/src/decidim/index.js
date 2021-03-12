import svg4everybody from 'svg4everybody'
import formDatePicker from './form_datepicker'
import fixDropdownMenus from './dropdowns_menus'
import Configuration from './configuration'
import ExternalLink from './external_link'
import createQuillEditor from './editor'
import InputCharacterCounter from './input_character_counter'
import FormValidator from './form_validator'
import './filters'
import CommentsComponent from '../../../../../decidim-comments/app/packs/src/decidim/comments/comments.component'

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()
window.Decidim.ExternalLink = ExternalLink;
window.Decidim.InputCharacterCounter = InputCharacterCounter;
window.Decidim.FormValidator = FormValidator;
window.Decidim.CommentsComponent = CommentsComponent;

$(() => {
  // TODO-blat
  // window.theDataPicker = new DataPicker($(".data-picker"));

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
});
