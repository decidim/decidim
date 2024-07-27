$(() => {
  const $limitedTimeRadioButton = $("#component_settings_proposal_edit_time_limited");
  const $infiniteTimeRadioButton = $("#component_settings_proposal_edit_time_infinite");
  const $editTimeContainer = $(".edit_time_container");

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
