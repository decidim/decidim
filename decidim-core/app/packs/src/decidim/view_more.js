$(() => {
  const $viewMoreComponent = $("[data-view-more]");

  if ($viewMoreComponent.length) {
    const $showMore = $("[data-show-more]");
    const $showLess = $("[data-show-less]");
    const $showMoreAction = $("[data-action-more]");
    const $showLessAction = $("[data-action-less]");

    $showLess.show();
    $showMore.hide();

    $showMoreAction.on("click", () => {
      $showMore.show();
      $showLess.hide();
    });

    $showLessAction.on("click", () => {
      $showLess.show();
      $showMore.hide();
    });
  }
});
