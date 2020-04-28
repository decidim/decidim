// = require ./budget_rule_toggler.component

((exports) => {
  const { BudgetRuleTogglerComponent } = exports.DecidimAdmin;

  const budgetRuleToggler = new BudgetRuleTogglerComponent({
    ruleCheckboxes: $("input[id^='component_settings_vote_rule_']")
  });

  budgetRuleToggler.run();
})(window);

// Checks if the form contains fields with special CSS classes added in
// Decidim::Admin::SettingsHelper and acts accordingly.
$(() => {
  // Prevents checkbox with ".participatory_texts_disabled" class from being clicked.
  const $participatoryTexts = $(".participatory_texts_disabled");

  $participatoryTexts.click((event) => {
    event.preventDefault();
    return false;
  });

  // Target fields:
  // - amendments_wizard_help_text
  // - all fields with ".amendments_step_settings" class
  // (1) Hides target fields if amendments_enabled component setting is NOT checked.
  // (2) Toggles visibilty of target fields when amendments_enabled component setting is clicked.
  const $amendmentsEnabled = $("input#component_settings_amendments_enabled");

  if ($amendmentsEnabled.length > 0) {
    const $amendmentWizardHelpText = $("[id*='amendments_wizard_help_text']").parent();
    const $amendmentStepSettings = $(".amendments_step_settings").parent();

    if ($amendmentsEnabled.is(":not(:checked)")) {
      $amendmentWizardHelpText.hide();
      $amendmentStepSettings.hide().siblings(".help-text").hide();
    }

    $amendmentsEnabled.click(() => {
      $amendmentWizardHelpText.toggle();
      $amendmentStepSettings.toggle().siblings(".help-text").toggle();
    });
  }
});
