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
// = require decidim/select2
// = require decidim/select2.field

/* globals svg4everybody */

window.Decidim = window.Decidim || {};

$(() => {
  $(document).foundation();
  svg4everybody();
  if (window.Decidim.formDatePicker) {
    window.Decidim.formDatePicker();
  }
});
