/* global sortSteps */

// = require jquery
// = require jquery_ujs
// = require foundation
// = require html.sortable
// = require ./sort_steps
// = require ./tab_focus
// = require ./toggle_nav
// = require decidim/editor
// = require foundation-datepicker
// = require form_datepicker
// = require moment.min
// = require_self

window.Decidim = window.Decidim || {};

const pageLoad = () => {
  $(document).foundation();

  sortSteps();

  if (DecidimAdmin) {
    DecidimAdmin.toggleNav();
  }
};

$(() => {
  pageLoad();

  if ($('.survey-questions-list:not(.published)').length > 0) {
    window.sortable('.survey-questions-list', {
      handle: "label",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true
    })[0].addEventListener('sortupdate', (event) => {
      const $questions = $(event.target).children();

      $questions.each((idx, el) => {
        $(el).find('input[name="survey[questions][][position]"]').val(idx);
      })
    });
  }

  if (window.Decidim.formDatePicker) {
    window.Decidim.formDatePicker();
  }
});
