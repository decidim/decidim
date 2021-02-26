/* eslint-disable no-invalid-this */
// TODO-blat this should import FormFilterComponent
import 'form_filter'

// Initializes the form filter.
((exports) => {
  const { Decidim: { FormFilterComponent } } = exports;

  $(() => {
    $("form.new_filter").each(function () {
      const formFilter = new FormFilterComponent($(this));

      formFilter.mountComponent();
    })
  });
})(window);
