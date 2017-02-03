// = require_self

$(() => {
  $(document).on("click", ".order-by a", (event) => {
    const $target = $(event.target);

    $target.parents('.menu').find('a:first').text($target.text());
  })
});
