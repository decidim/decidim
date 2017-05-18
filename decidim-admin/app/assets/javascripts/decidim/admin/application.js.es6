/* global sortSteps */

// = require jquery
// = require jquery_ujs
// = require foundation
// = require ./tab_focus
// = require ./toggle_nav
// = require ./sort_list
// = require decidim/editor
// = require foundation-datepicker
// = require form_datepicker
// = require moment.min
// = require_self

window.Decidim = window.Decidim || {};

const pageLoad = () => {
  $(document).foundation();

  if (DecidimAdmin) {
    DecidimAdmin.toggleNav();

    DecidimAdmin.sortList('#steps tbody', {
      placeholder: $('<tr style="border-style: dashed; border-color: #000"><td colspan="4">&nbsp;</td></tr>')[0],
      onSortUpdate: ($children) => {
        const sortUrl = $('#steps tbody').data('sort-url')
        const order = $children.map((index, child) => $(child).data('id')).toArray();

        $.ajax({
          method: 'POST',
          url: sortUrl,
          contentType: 'application/json',
          data: JSON.stringify({ items_ids: order }) }, // eslint-disable-line camelcase
        );
      }
    })
  }
};

$(() => {
  pageLoad();

  if (window.Decidim.formDatePicker) {
    window.Decidim.formDatePicker();
  }
});
