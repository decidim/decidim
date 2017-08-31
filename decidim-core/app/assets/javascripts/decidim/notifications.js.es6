$(() => {
  const $section = $('section#unread-notifications');
  const $wrapper = $('#notifications');

  $section.on('click', '.mark-as-read-button', (event) => {
    $(event.target).parents('.card--list__item').fadeOut(1000);
  });

  $wrapper.on('click', '.mark-all-as-read-button', (_event) => {
    $section.fadeOut(1000);
  });
});
