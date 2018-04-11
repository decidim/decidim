(function() {
  $(() => {

    $(".show-more").on("click", function() {
      /* eslint-disable no-invalid-this */
      $(this).hide();
      $(".show-more-panel").removeClass("hide");
      $(".hide-more").show();
    });

    $(".hide-more").on("click", function() {
      $(this).hide();
      $(".show-more-panel").addClass("hide");
      $(".show-more").show();
    });

  })
}(window));
