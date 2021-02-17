$(() => {
  const $labelFalse = $("label[for='component_settings_proposal_edit_time_limited']")
  const $inputFalse = $("#component_settings_proposal_edit_time_limited")
  const $inputTrue = $("#component_settings_proposal_edit_time_infinite")
  const $editTimeContainer = $(".proposal_edit_before_minutes_container")

  $editTimeContainer.detach().appendTo($labelFalse)

  if ($inputTrue.is(":checked")) {
    $editTimeContainer.hide();
  }

  $inputFalse.on("click", () => {
    $editTimeContainer.show();
  })

  $inputTrue.on("click", () => {
    $editTimeContainer.hide();
  })
})
