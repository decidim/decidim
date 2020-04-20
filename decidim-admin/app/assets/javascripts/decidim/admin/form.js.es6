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
  // Prevents disabled containers from being modified.
  const $disabledContainer = $(".disabled_container input");

  $disabledContainer.click((event) => {
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
    const $amendmentStepSettings = $(".amendments_visibility_container, .amendment_creation_enabled_container, .amendment_reaction_enabled_container, .amendment_promotion_enabled_container");

    if ($amendmentsEnabled.is(":not(:checked)")) {
      $amendmentStepSettings.hide();
    }

    $amendmentsEnabled.click(() => {
      $amendmentStepSettings.toggle();
    });
  }
});
