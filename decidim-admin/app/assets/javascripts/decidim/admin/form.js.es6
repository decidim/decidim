// Checks if the form contains fields with special CSS classes added in
// Decidim::Admin::SettingsHelper and acts accordingly.
$(() => {
  // Prevents checkbox with ".participatory_texts_disabled" class from being clicked.
  const $participatoryTexts = $(".participatory_texts_disabled");

  $participatoryTexts.click((event) => {
    event.preventDefault();
    return false;
  });

  // Toggles visibilty of fields with ".amendments_step_settings" class
  // when amendments_enabled global setting is clicked.
  const $amendmentsEnabled = $("input#component_settings_amendments_enabled");

  if ($amendmentsEnabled.length > 0) {

    $amendmentsEnabled.click(() => {
      const $amendmentStepSettings = $(".amendments_step_settings").parent();

      $amendmentStepSettings.toggle().siblings(".help-text").toggle();
    });
  }
});
