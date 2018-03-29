/* eslint-disable no-invalid-this */

(function() {
  $(() => {

    $(".show-more").on("click", function() {
      $(this).hide();
      $(".show-more-panel").removeClass("hide");
    });

  })
}(window));
