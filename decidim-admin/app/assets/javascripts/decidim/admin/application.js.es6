//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require html.sortable
//= require ./sort_steps
//= require decidim/editor
//= require_self

$(document).on('turbolinks:load', () => {
  $(() => { $(document).foundation(); });
});

