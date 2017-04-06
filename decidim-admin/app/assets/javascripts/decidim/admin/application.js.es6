/* global sortSteps */

// = require jquery
// = require jquery_ujs
// = require foundation
// = require html.sortable
// = require ./sort_steps
// = require ./tab_focus
// = require decidim/editor
// = require moment.min
// = require foundation-datepicker
// = require form_datepicker
// = require_self

window.DecidimAdmin = window.DecidimAdmin || {};

const pageLoad = () => {
  $(document).foundation();
  sortSteps();
};

$(() => {
  pageLoad();
  if (window.DecidimAdmin.formDatePicker) {
    window.DecidimAdmin.formDatePicker();
  }
});
