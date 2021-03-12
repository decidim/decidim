import toggleNav from './toggle_nav'
import createSortList from './sort_list.component'
import createQuillEditor from '../../../../../../decidim-core/app/packs/src/decidim/editor'
import formDatePicker from '../../../../../../decidim-core/app/packs/src/decidim/form_datepicker'
import DataPicker from '../../../../../../decidim-core/app/packs/src/decidim/data_picker'

window.Decidim = window.Decidim || {};
window.DecidimAdmin = window.DecidimAdmin || {};

const pageLoad = () => {
  $(document).foundation();

  toggleNav();

  // TODO-blat: remove Typescript and import this module
  // renderAutocompleteSelects('[data-plugin="autocomplete"]');

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
  window.theDataPicker = new DataPicker($(".data-picker"));

  pageLoad();

  formDatePicker();

  $(".editor-container").each((_idx, container) => {
    createQuillEditor(container);
  });
});
