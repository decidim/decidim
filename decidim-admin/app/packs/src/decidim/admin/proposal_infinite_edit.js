$(() => {
  const $limitiedTimeLabel = $("label[for='component_settings_proposal_edit_time_limited']")
  const $limitedTimeRadioButton = $("#component_settings_proposal_edit_time_limited")
  const $infiniteTimeRadioButton = $("#component_settings_proposal_edit_time_infinite")
  const $editTimeContainer = $(".proposal_edit_before_minutes_container")

  $editTimeContainer.detach().appendTo($limitiedTimeLabel)

  if ($infiniteTimeRadioButton.is(":checked")) {
    $editTimeContainer.hide();
  }

  $limitedTimeRadioButton.on("click", () => {
    $editTimeContainer.show();
  })

  $infiniteTimeRadioButton.on("click", () => {
    $editTimeContainer.hide();
  })
})
