/* eslint-disable no-invalid-this */
import FormFilterComponent from './form_filter'

$(() => {
  $("form.new_filter").each(function () {
    const formFilter = new FormFilterComponent($(this));

    formFilter.mountComponent();
  })
});
