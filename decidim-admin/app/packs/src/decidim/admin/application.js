require("@rails/ujs").start()
import $ from 'jquery'
import 'foundation-sites'
import 'foundation-datepicker'
import 'jquery.autocomplete'
import 'jquery-serializejson'
import 'html5sortable'

import './tab_focus'
import './choose_language'
import toggleNav from './toggle_nav'
import createSortList from './sort_list.component'
import '../../../../../../decidim-core/app/packs/src/decidim/editor'
import formDatePicker from '../../../../../../decidim-core/app/packs/src/decidim/form_datepicker'
import DataPicker from '../../../../../../decidim-core/app/packs/src/decidim/data_picker'
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
import '../../../../../../decidim-core/app/packs/src/decidim/session_timeouter'

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

  if (window.Decidim.quillEditor) {
    window.Decidim.quillEditor();
  }
});
