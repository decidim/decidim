$(() => {
  const $initialNotificationLabel = $("#component_settings_enable_cr_initial_notifications")
  const $initialNotificationInput = $(".close_report_notifications_container")
  const $reminderNotificationLabel = $("#component_settings_enable_cr_reminder_notifications")
  const $reminderNotificationInput = $(".close_report_reminder_notifications_container")

  $initialNotificationLabel.on("click", () => {
    if ($initialNotificationLabel.is(":checked")) {
      $initialNotificationInput.show();
    } else {
      $initialNotificationInput.hide();
    }
  })

  $reminderNotificationLabel.on("click", () => {
    if ($reminderNotificationLabel.is(":checked")) {
      $reminderNotificationInput.show();
    } else {
      $reminderNotificationInput.hide();
    }
  })
})
