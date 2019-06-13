// Checks if the form contains fields special CSS classes added in
// Decidim::Admin::SettingsHelper and acts accordingly.
$(() => {
  // Prevents checkbox with ".participatory_texts_disabled" class from being clicked.
  const $participatory_texts = $(".participatory_texts_disabled");

  $participatory_texts.click((event) => {
    event.preventDefault();
    return false;
  });

  // Toggles visibilty of fields with ".amendments_step_settings" class
  // when amendments_enabled global setting is clicked.
  const $amendments_enabled = $('input#component_settings_amendments_enabled');

  if ($amendments_enabled.length > 0) {

    $amendments_enabled.click(() => {
      const $amendment_step_settings = $(".amendments_step_settings").parent();

      $amendment_step_settings.toggle().siblings(".help-text").toggle();
    });
  }
});
