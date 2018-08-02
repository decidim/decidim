// = require jquery
// = require foundation
// = require rails-ujs
// = require ./tab_focus
// = require ./toggle_nav
// = require ./sort_list.component
// = require decidim/editor
// = require foundation-datepicker
// = require form_datepicker
// = require moment.min
// = require decidim/data_picker
// = require jquery.auto-complete
// = require ./auto_label_by_position.component
// = require ./auto_buttons_by_position.component
// = require ./dynamic_fields.component
// = require ./field_dependent_inputs.component
// = require ./bundle
// = require ./draggable-list
// = require decidim/input_tags
// = require decidim/input_hashtags
// = require_self

window.Decidim = window.Decidim || {};
window.DecidimAdmin = window.DecidimAdmin || {};

const pageLoad = () => {
  const { toggleNav, createSortList, renderAutocompleteSelects } = window.DecidimAdmin;

  $(document).foundation();

  toggleNav();

  renderAutocompleteSelects('[data-plugin="autocomplete"]');

  createSortList("#steps tbody", {
    placeholder: $('<tr style="border-style: dashed; border-color: #000"><td colspan="4">&nbsp;</td></tr>')[0],
    onSortUpdate: ($children) => {
      const sortUrl = $("#steps tbody").data("sort-url")
      const order = $children.map((index, child) => $(child).data("id")).toArray();

      $.ajax({
        method: "POST",
        url: sortUrl,
        contentType: "application/json",
        data: JSON.stringify({ items_ids: order }) }, // eslint-disable-line camelcase
      );
    }
  })
};

$(() => {
  if (window.Decidim.DataPicker) {
    window.theDataPicker = new window.Decidim.DataPicker($(".data-picker"));
  }

  pageLoad();

  if (window.Decidim.formDatePicker) {
    window.Decidim.formDatePicker();
  }

  if (window.Decidim.quillEditor) {
    window.Decidim.quillEditor();
  }
});
