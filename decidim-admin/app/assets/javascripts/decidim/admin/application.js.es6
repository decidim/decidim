//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require html.sortable.min
//= require quill.min
//= require ./sort_steps
//= require_self

$(document).on('turbolinks:load', () => {
  $(() => { $(document).foundation(); });
});

