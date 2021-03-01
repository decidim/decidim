import $ from 'jquery'
// TODO-blat: import 'jquery3'
require("@rails/ujs").start()
import 'foundation-sites'
import 'foundation-datepicker'
import 'moment'
import 'jquery.autocomplete'
import 'jquery-serializejson'
import 'html5sortable'

import './tab_focus'
import './choose_language'
import './toggle_nav'
import './sort_list.component'
import '../../../../../../decidim-core/app/packs/src/decidim/editor'
import '../../../../../../decidim-core/app/packs/src/decidim/form_datepicker'
import '../../../../../../decidim-core/app/packs/src/decidim/data_picker'
import './auto_label_by_position.component'
import './auto_buttons_by_position.component'
import './dynamic_fields.component'
import './field_dependent_inputs.component'
// TODO-blat include the autocomplete component
// import './bundle'
import './draggable-list'
import './sortable'
import './gallery'
import './moderations'
import '../../../../../../decidim-core/app/packs/src/decidim/input_tags'
import '../../../../../../decidim-core/app/packs/src/decidim/input_hashtags'
import '../../../../../../decidim-core/app/packs/src/decidim/input_mentions'
import '../../../../../../decidim-core/app/packs/src/decidim/vizzs'
import '../../../../../../decidim-core/app/packs/src/decidim/ajax_modals'
import './officializations'
import '../../../../../../decidim-core/app/packs/src/decidim/input_character_counter'
import '../../../../../../decidim-core/app/packs/src/decidim/geocoding/attach_input'
import '../../../../../../decidim-core/app/packs/src/decidim/session_timeouter'

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
