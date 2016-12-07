/* global sortSteps */

// = require jquery
// = require jquery_ujs
// = require foundation
// = require turbolinks
// = require html.sortable
// = require ./sort_steps
// = require ./tab_focus
// = require decidim/editor
// = require_self

function pageLoad() {
  $(document).foundation();
  sortSteps();
}

$(document).on('turbolinks:load', pageLoad);
$(pageLoad);
