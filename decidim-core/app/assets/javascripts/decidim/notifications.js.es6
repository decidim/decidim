$(() => {
  const $wrapper = $('#notifications');
  const $section = $wrapper.find('section#notifications-list');
  const $noNotificationsText = $wrapper.find('.empty-notifications');
  const $pagination = $wrapper.find('ul.pagination');
  const FADEOUT_TIME = 500;

  const anyNotifications = () => $wrapper.find('.card--list__item').length > 0;
  const emptyNotifications = () => {
    if (!anyNotifications()) {
      $section.remove();
      $noNotificationsText.removeClass('hide');
    }
  };

  $section.on('click', '.mark-as-read-button', (event) => {
    const $item = $(event.target).parents('.card--list__item');
    $item.fadeOut(FADEOUT_TIME, () => {
      $item.remove();
      emptyNotifications();
    });
  });

  $wrapper.on('click', '.mark-all-as-read-button', () => {
    $section.fadeOut(FADEOUT_TIME, () => {
      $pagination.remove();
      $wrapper.find('.card--list__item').remove();
      emptyNotifications();
    });
  });

  emptyNotifications();
});
