$(() => {
  const $notificationsBellIcon = $(".title-bar .topbar__notifications");
  const $wrapper = $(".tabs-content");
  const $section = $wrapper.find("#notifications");
  const $noNotificationsText = $(".empty-notifications");
  const $pagination = $wrapper.find("ul.pagination");
  const FADEOUT_TIME = 500;

  const anyNotifications = () => $wrapper.find(".card--widget").length > 0;
  const emptyNotifications = () => {
    if (!anyNotifications()) {
      $section.remove();
      $noNotificationsText.removeClass("hide");
    }
  };

  $section.on("click", ".mark-as-read-button", (event) => {
    const $item = $(event.target).parents(".card--widget");
    $item.fadeOut(FADEOUT_TIME, () => {
      $item.remove();
      emptyNotifications();
    });
  });

  $wrapper.on("click", ".mark-all-as-read-button", () => {
    $section.fadeOut(FADEOUT_TIME, () => {
      $pagination.remove();
      $notificationsBellIcon.removeClass("is-active");
      $wrapper.find(".card--widget").remove();
      emptyNotifications();
    });
  });

  emptyNotifications();
});
