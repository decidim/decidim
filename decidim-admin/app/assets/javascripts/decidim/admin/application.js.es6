//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require html.sortable.min
//= require ./sort_steps
//= require decidim/editor
//= require_self

$(document).on('turbolinks:load', () => {
  $(() => { $(document).foundation(); });
});

