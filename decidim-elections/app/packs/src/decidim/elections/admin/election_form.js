$(() => {
  const $manualStart = $("#election_manual_start");
  const $datepickerRow = $(".election_start_time");

  if ($manualStart.length === 0 || $datepickerRow.length === 0) {
    return;
  }

  const toggleVisibility = () => {
    if ($manualStart.is(":checked")) {
      $datepickerRow.hide();
    } else {
      $datepickerRow.show();
    }
  };

  $manualStart.on("change", toggleVisibility);
  toggleVisibility();
});
