// = require ./form_filter.component
// = require_self

// Initializes the form filter. We're unmounting the component before
// changing the page so that we stop listening to events and we don't bind
// multiple times when re-visiting the page.
((exports) => {
  const { Decidim: { FormFilterComponent } } = exports;
  const formFilter = new FormFilterComponent('form.new_filter');

  $(() => {
    formFilter.mountComponent();
  });
})(window);
