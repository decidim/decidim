/* global sortSteps */

// = require jquery
// = require jquery_ujs
// = require foundation
// = require html.sortable
// = require ./sort_steps
// = require ./tab_focus
// = require decidim/editor
// = require_self

const pageLoad = () => {
  $(document).foundation();
  sortSteps();
};

$(() => {
  pageLoad();
});
