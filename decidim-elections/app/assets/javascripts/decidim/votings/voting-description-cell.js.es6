(function() {
  $(() => {
    $(".voting-description-cell .content-height-toggler .button").on("click", function(event) {
      let $button = $(event.target);
      let $content = $button.closest(".voting-description-cell").find(".content");
      let $buttonTextMore = $button.find(".button-text.show-more-content");
      let $buttonTextLess = $button.find(".button-text.show-less-content");

      $buttonTextLess.removeClass("hide").hide();
      $content.toggleClass("content__expanded");

      if ($content.hasClass("content__expanded")) {
        $buttonTextMore.hide();
        $buttonTextLess.show();
      } else {
        $buttonTextLess.hide();
        $buttonTextMore.show();
      }
    });
  })
}(window));
