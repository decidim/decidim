/* eslint-disable no-invalid-this */
// = require ./form_filter.component
// = require_self

// Initializes the form filter.
((exports) => {
  const { Decidim: { FormFilterComponent } } = exports;

  $(() => {
    $('form.new_filter').each(function () {
      const formFilter = new FormFilterComponent($(this));

      formFilter.mountComponent();
    })
  });
})(window);
