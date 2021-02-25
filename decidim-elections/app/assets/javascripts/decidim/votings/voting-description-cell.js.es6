(function() {
  $(() => {
    let remToPx = function(count) {
      let unit = $("html").css("font-size");

      if (typeof count !== "undefined" && count > 0) {
        return (parseInt(unit, 0) * count);
      }
      return parseInt(unit, 0);
    }

    let $button = $(".voting-description-cell .content-height-toggler .button");
    let $content = $button.closest(".voting-description-cell").find(".content");
    let $contentContentMaxHeight = remToPx(7.8);

    if ($content.height() < $contentContentMaxHeight) {
      $button.hide();
    }

    $button.on("click", function() {
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
