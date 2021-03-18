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

  let contentMaxHeight = remToPx(7.8);
  if ($("#introductory-image").length) {
    contentMaxHeight = $("#introductory-image").height();
  }

  if (contentHeight < contentMaxHeight) {
    $button.hide();
  } else {
    $content.css("max-height", contentMaxHeight)
  }

  $button.on("click", (event) => {
    const $buttonTextMore = $button.find(".button-text.show-more-content");
    const $buttonTextLess = $button.find(".button-text.show-less-content");

    let newHeight = contentMaxHeight;
    if (isShowMoreButton($(event.target))) {
      newHeight = contentHeight;
    }

    $content.css("max-height", newHeight);
    $buttonTextLess.toggleClass("hide");
    $buttonTextMore.toggleClass("hide");
  });
})
