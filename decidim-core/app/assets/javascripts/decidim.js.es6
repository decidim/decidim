// = require jquery
// = require rails-ujs
// = require decidim/foundation
// = require modernizr
// = require svg4everybody.min
// = require morphdom
// = require moment.min
// = require foundation-datepicker
// = require form_datepicker

// = require decidim/history
// = require decidim/append_elements
// = require decidim/user_registrations
// = require decidim/account_form
// = require decidim/data_picker
// = require decidim/append_redirect_url_to_modals
// = require decidim/editor
// = require decidim/input_tags
// = require decidim/input_mentions
// = require decidim/ajax_modals
// = require decidim/conferences
// = require_tree ./decidim/vizzs

/* globals svg4everybody */

window.Decidim = window.Decidim || {};

$(() => {
  if (window.Decidim.DataPicker) {
    window.theDataPicker = new window.Decidim.DataPicker($(".data-picker"));
  }

  $(document).foundation();

  svg4everybody();

  if (window.Decidim.formDatePicker) {
    window.Decidim.formDatePicker();
  }

  if (window.Decidim.quillEditor) {
    window.Decidim.quillEditor();
  }
});
