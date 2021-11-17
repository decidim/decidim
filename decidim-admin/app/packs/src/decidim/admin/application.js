/* eslint-disable no-invalid-this */

import toggleNav from "src/decidim/admin/toggle_nav"
import createSortList from "src/decidim/admin/sort_list.component"
import createQuillEditor from "src/decidim/editor"
import formDatePicker from "src/decidim/form_datepicker"
import DataPicker from "src/decidim/data_picker"
import FormFilterComponent from "src/decidim/form_filter"
import Configuration from "src/decidim/configuration"
import InputCharacterCounter from "src/decidim/input_character_counter"
import managedUsersForm from "src/decidim/admin/managed_users"

window.Decidim = window.Decidim || {};
window.Decidim.managedUsersForm = managedUsersForm
window.Decidim.config = new Configuration()
window.Decidim.InputCharacterCounter = InputCharacterCounter;

$(() => {
  window.theDataPicker = new DataPicker($(".data-picker"));

  $(document).foundation();

  toggleNav();

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

  $("form.new_filter").each(function () {
    const formFilter = new FormFilterComponent($(this));

    formFilter.mountComponent();
  })
});

