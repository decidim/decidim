// Checks if the form contains a field with a special CSS class added in
// Decidim::Admin::SettingsHelper.
// when .participatory_texts_disabled, prevents the checkbox from being clicked.
// or .field_has_help_text, extracts the stored text and
// adds a new paragraph after the field.
$(() => {
  const $checkboxes = $(".field_has_help_text, .participatory_texts_disabled");

  if ($checkboxes.length > 0) {
    $checkboxes.each(function(index, element) {
      let $checkbox = $(element);

      if ($checkbox.hasClass("participatory_texts_disabled") > 0) {
        $checkbox.click((event) => {
          event.preventDefault();
          return false;
        });
      }

      if ($checkbox.hasClass("field_has_help_text") > 0) {
        let $text = $checkbox.data("text");
        $checkbox.closest("label").after(`<p class="help-text">${$text}</p>`);
      }
    });
  }
});
