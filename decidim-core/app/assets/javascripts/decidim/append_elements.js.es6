// = require appendAround

(function() {
  $(document).on("turbolinks:load", function () {
    let $appendableElements = $('.js-append');
    $appendableElements.appendAround();
  })
}(window));
