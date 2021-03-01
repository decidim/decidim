((exports) => {
  const $ = exports.$; // eslint-disable-line

  $(() => {
    const $moderationDetails = $(".moderation-details");
    const $toggleContentButton = $moderationDetails.find(".toggle-content");
    const $reportedContent = $moderationDetails.find(".reported-content");
    const $currentContent = $reportedContent.find(".current");
    const $originalContent = $reportedContent.find(".original");

    $originalContent.hide();

    $toggleContentButton.on("click", () => {
      $currentContent.toggle();
      $originalContent.toggle();

      if ($currentContent.is(":hidden")) {
        $toggleContentButton.html($toggleContentButton.data("see-current-button-label"));
      } else {
        $toggleContentButton.html($toggleContentButton.data("see-original-button-label"));
      }
    })
  })
})(window)
