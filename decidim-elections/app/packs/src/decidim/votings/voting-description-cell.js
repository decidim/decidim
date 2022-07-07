$(() => {
  const remToPx = (count) => {
    const unit = $("html").css("font-size");

    if (typeof count !== "undefined" && count > 0) {
      return (parseInt(unit, 10) || 0) * count;
    }
    return parseInt(unit, 10) || 0;
  };

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
    $content.css("max-height", contentMaxHeight);
  }

  $button.on("click", () => {
    const $buttonTextLess = $button.find(".button-text.show-less-content");

    let newHeight = contentMaxHeight;

    $content.css("max-height", newHeight);
    $buttonTextLess.toggleClass("hide");
  });
});
