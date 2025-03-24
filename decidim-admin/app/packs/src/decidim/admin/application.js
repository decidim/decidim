/* eslint-disable no-invalid-this */

import toggleNav from "src/decidim/admin/toggle_nav";
import createSortList from "src/decidim/admin/sort_list.component";
import FormFilterComponent from "src/decidim/form_filter";
import Configuration from "src/decidim/configuration";
import InputCharacterCounter from "src/decidim/input_character_counter";
import managedUsersForm from "src/decidim/admin/managed_users";

import "chartkick/chart.js";

window.Decidim = window.Decidim || {};
window.Decidim.managedUsersForm = managedUsersForm;
window.Decidim.config = new Configuration();
window.Decidim.InputCharacterCounter = InputCharacterCounter;

// REDESIGN_PENDING: deprecated
window.initFoundation = (element) => {
  $(element).foundation();
};

$(() => {
  window.initFoundation(document);

  $(document).on("show.zf.dropdownMenu", function(event, $element) {
    $element.attr("aria-hidden", "false");
  });

  $(document).on("hide.zf.dropdownMenu", function(event, $element) {
    $element.children(".is-dropdown-submenu").attr("aria-hidden", "true");
  });

  toggleNav();

  createSortList("#steps tbody", {
    placeholder: $(
      '<tr style="border-style: dashed; border-color: #000"><td colspan="4">&nbsp;</td></tr>'
    )[0],
    onSortUpdate: ($children) => {
      const sortUrl = $("#steps tbody").data("sort-url");
      const order = $children.
        map((index, child) => $(child).data("id")).
        toArray();

      $.ajax({
        method: "POST",
        url: sortUrl,
        contentType: "application/json",
        data: JSON.stringify({ items_ids: order }) // eslint-disable-line camelcase
      });
    }
  });

  $("form.new_filter").each(function () {
    const formFilter = new FormFilterComponent($(this));

    formFilter.mountComponent();
  });
});
