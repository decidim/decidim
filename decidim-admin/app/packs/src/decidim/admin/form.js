import "src/decidim/admin/proposal_infinite_edit"

import BudgetRuleTogglerComponent from "src/decidim/admin/budget_rule_toggler.component"

// Checks if the form contains fields with special CSS classes added in
// Decidim::Admin::SettingsHelper and acts accordingly.
$(() => {
  const budgetRuleToggler = new BudgetRuleTogglerComponent({
    ruleCheckboxes: $("input[id^='component_settings_vote_rule_']")
  });

  budgetRuleToggler.run();

  // Prevents readonly containers from being modified.
  const $readonlyContainer = $(".readonly_container input");

  $readonlyContainer.click((event) => {
    event.preventDefault();
    return false;
  });

  // Target fields:
  // - amendments_wizard_help_text
  // - amendments_visibility
  // - amendment_creation_enabled
  // - amendment_reaction_enabled
  // - amendment_promotion_enabled

  // (1) Hides target fields if amendments_enabled component setting is NOT checked.
  // (2) Toggles visibility of target fields when amendments_enabled component setting is clicked.
  const $amendmentsEnabled = $("input#component_settings_amendments_enabled");

  if ($amendmentsEnabled.length > 0) {
    const $amendmentStepSettings = $(".amendments_wizard_help_text_container, .amendments_visibility_container, .amendment_creation_enabled_container, .amendment_reaction_enabled_container, .amendment_promotion_enabled_container");

    if ($amendmentsEnabled.is(":not(:checked)")) {
      $amendmentStepSettings.hide();
    }

    $amendmentsEnabled.click(() => {
      $amendmentStepSettings.toggle();
    });
  }

  // Toggles visibility of the attachments_allowed help text when the checkbox is clicked.
  // Show the help text if the checkbox is checked.
  const $attachmentsAllowedCheckbox = $("#component_settings_attachments_allowed");
  const $attachmentsHelpText = $(".attachments_allowed_container .help-text");

  if (!$attachmentsAllowedCheckbox.is(":checked")) {
    $attachmentsHelpText.hide();
  }

  $attachmentsAllowedCheckbox.on("change", () => {
    if ($attachmentsAllowedCheckbox.is(":checked")) {
      $attachmentsHelpText.show();
    } else {
      $attachmentsHelpText.hide();
    }
  });
});
