import * as React from "react";
import * as ReactDOM from "react-dom";
import toggleNav from "./toggle_nav"
import createSortList from "./sort_list.component"
import createQuillEditor from "../../../../../../decidim-core/app/packs/src/decidim/editor"
import formDatePicker from "../../../../../../decidim-core/app/packs/src/decidim/form_datepicker"
import DataPicker from "../../../../../../decidim-core/app/packs/src/decidim/data_picker"
import Autocomplete from "./autocomplete.component";

const renderAutocompleteSelects = (nodeSelector) => {
  window.$(nodeSelector).each((index, node) => {
    const props = { ...window.$(node).data("autocomplete") };

    ReactDOM.render(
      React.createElement(Autocomplete, props),
      node
    );
  });
};

$(() => {
  window.theDataPicker = new DataPicker($(".data-picker"));

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

  formDatePicker();

  $(".editor-container").each((_idx, container) => {
    createQuillEditor(container);
  });
});

