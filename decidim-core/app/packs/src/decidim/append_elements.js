import '@zeitiger/appendaround'

(function() {
  $(() => {
    let $appendableElements = $(".js-append");
    $appendableElements.appendAround();
  })
}(window));
