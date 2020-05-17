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
// = require decidim/input_multiple_mentions
// = require decidim/input_character_counter
// = require decidim/ajax_modals
// = require decidim/conferences
// = require decidim/tooltip_keep_on_hover
// = require decidim/diff_mode_dropdown
// = require decidim/check_boxes_tree
// = require decidim/conversations
// = require decidim/delayed
// = require decidim/icon
// = require decidim/external_links
// = require decidim/vizzs
// = require decidim/responsive_horizontal_tabs.js

// = require_self
// = require decidim/configuration
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

  // Prevent data-open buttons e.g. from submitting the underlying form in
  // authorized action buttons.
  $("[data-open]").on("click", (event) => {
    event.preventDefault();
  });

  if (window.Decidim.formDatePicker) {
    window.Decidim.formDatePicker();
  }

  if (window.Decidim.quillEditor) {
    window.Decidim.quillEditor();
  }
});
