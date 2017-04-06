/* global sortSteps */

// = require jquery
// = require jquery_ujs
// = require foundation
// = require html.sortable
// = require ./sort_steps
// = require ./tab_focus
// = require decidim/editor
// = require foundation-datepicker
// = require form_datepicker
// = require moment.min
// = require_self

window.Decidim = window.Decidim || {};

const pageLoad = () => {
  $(document).foundation();
  sortSteps();
};

$(() => {
  pageLoad();
 if (window.Decidim.formDatePicker) {
    window.Decidim.formDatePicker();
  }
});