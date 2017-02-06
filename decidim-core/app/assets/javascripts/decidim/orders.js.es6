// = require_self

$(() => {
  const { pushState, registerCallback } = window.Decidim.History;

  $(document).on("click", ".order-by a", (event) => {
    const $target = $(event.target);

    $target.parents('.menu').find('a:first').text($target.text());

    pushState($target.attr('href'));
  })

  registerCallback("orders", () => {
    const url = window.location.toString();
    const match = url.match(/order=([^&]*)/);
    const $orderMenu = $('.order-by .menu');
    let order = $orderMenu.find('.menu a:first').data('order');

    if (match) {
      order = match[1];
    }

    const linkText = $orderMenu.find(`.menu a[data-order="${order}"]`).text();

    $orderMenu.find('a:first').text(linkText);
  });
});
