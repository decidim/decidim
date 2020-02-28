// = require decidim/core/bundle.js
// = require jquery3
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
// = require decidim/input_hashtags
// = require decidim/input_mentions
// = require decidim/ajax_modals
// = require decidim/conferences
// = require decidim/tooltip_keep_on_hover
// = require decidim/diff_mode_dropdown
// = require decidim/check_boxes_tree
// = require decidim/delayed
// = require_tree ./decidim/vizzs

// = require_self
// = require decidim/floating_help

/* globals svg4everybody */

window.Decidim = window.Decidim || {};

$(() => {
  if (window.Decidim.DataPicker) {
    window.theDataPicker = new window.Decidim.DataPicker($(".data-picker"));
  }
  if (window.Decidim.CheckBoxesTree) {
    window.theCheckBoxesTree = new window.Decidim.CheckBoxesTree();
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
