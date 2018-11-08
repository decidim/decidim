(() => {
  const $scope = $("#welcome-notification-details");

  const $sendNotificationCheckbox = $(
    "#organization_send_welcome_notification",
    $scope
  );

  const $customizeCheckbox = $(
    "#organization_customize_welcome_notification",
    $scope
  );

  const toggleVisibility = () => {
    if ($sendNotificationCheckbox.is(":checked")) {
      $(".send-welcome-notification-details", $scope).show();
    } else {
      $(".send-welcome-notification-details", $scope).hide();
    }

    if ($customizeCheckbox.is(":checked")) {
      $(".customize-welcome-notification-details", $scope).show();
    } else {
      $(".customize-welcome-notification-details", $scope).hide();
    }
  };

  $($sendNotificationCheckbox).click(() => toggleVisibility());
  $($customizeCheckbox).click(() => toggleVisibility());

  toggleVisibility();
})();
