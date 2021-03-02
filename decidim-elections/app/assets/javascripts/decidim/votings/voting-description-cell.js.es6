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
    let $contentMaxHeight = remToPx(7.8);

    if ($content.height() < $contentMaxHeight) {
      $button.hide();
      $content.addClass("unexpandable")
    }

    $button.on("click", function() {
      let $buttonTextMore = $button.find(".button-text.show-more-content");
      let $buttonTextLess = $button.find(".button-text.show-less-content");

      $content.toggleClass("content__expanded");
      $buttonTextLess.toggleClass("hide");
      $buttonTextMore.toggleClass("hide");
    });
  })
}(window));
