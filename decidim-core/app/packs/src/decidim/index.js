import svg4everybody from 'svg4everybody'
import formDatePicker from './form_datepicker'
import DataPicker from './data_picker'
import fixDropdownMenus from './dropdowns_menus'
import Configuration from './configuration'
import ExternalLink from './external_link'
import createQuillEditor from './editor'

window.Decidim = window.Decidim || {};

$(() => {
  window.theDataPicker = new DataPicker($(".data-picker"));
  window.Decidim.config = new Configuration()

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
