$(() => {
  const isShowMoreButton = ($button) => $button.hasClass("show-more-content");
  
  const remToPx = (count) => {
    const unit = $("html").css("font-size");

    if (typeof count !== "undefined" && count > 0) {
      return (parseInt(unit, 0) * count);
    }
    return parseInt(unit, 0);
  }

  const $button = $(".voting-description-cell .content-height-toggler .button");
  const $content = $button.closest(".voting-description-cell").find(".content");
  const contentHeight = $content.height();
  const contentMaxHeight = $("#introductory-image").length ? $("#introductory-image").height() : remToPx(7.8);

  if (contentHeight < contentMaxHeight) {
    $button.hide();
  } else {
    $content.css("max-height", contentMaxHeight)
  }

  $button.on("click", (event) => {
    const $buttonTextMore = $button.find(".button-text.show-more-content");
    const $buttonTextLess = $button.find(".button-text.show-less-content");

    const newHeight = isShowMoreButton($(event.target)) ? contentHeight : contentMaxHeight;
    $content.css("max-height", newHeight);
    $buttonTextLess.toggleClass("hide");
    $buttonTextMore.toggleClass("hide");
  });
})
