// Checks if the form contains fields with special CSS classes added in
// Decidim::Admin::SettingsHelper and acts accordingly.
$(() => {
  // Prevents checkbox with ".participatory_texts_disabled" class from being clicked.
  const $participatoryTexts = $(".participatory_texts_disabled");

  $participatoryTexts.click((event) => {
    event.preventDefault();
    return false;
  });

  // (1) Hides fields with ".amendments_step_settings" class if amendments_enabled
  // component setting is NOT checked.
  // (2) Toggles visibilty of fields with ".amendments_step_settings" class when
  // amendments_enabled component setting is clicked.
  const $amendmentsEnabled = $("input#component_settings_amendments_enabled");

  if ($amendmentsEnabled.length > 0) {
    const $amendmentStepSettings = $(".amendments_step_settings").parent();

    if ($amendmentsEnabled.is(":not(:checked)")) {
      $amendmentStepSettings.hide().siblings(".help-text").hide();
    }

    $amendmentsEnabled.click(() => {
      $amendmentStepSettings.toggle().siblings(".help-text").toggle();
    });
  }
});
