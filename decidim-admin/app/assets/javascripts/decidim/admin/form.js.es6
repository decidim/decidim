// Checks if the form contains a field with a special CSS class added in
// Decidim::Admin::SettingsHelper. If so, prevents the checkbox from being clicked,
// extracts the stored text and adds a new paragraph after the field.
$(() => {
  const $checkbox = $(".participatory_texts_disabled");

  $checkbox.click((event) => {
    event.preventDefault();
    return false;
  });

  if ($checkbox.length > 0) {
    const $text = $checkbox[0].dataset.text

    $checkbox.parent().after(`<p class="help-text">${$text}</p>`)
  }
});
