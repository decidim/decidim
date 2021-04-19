/* eslint-disable no-invalid-this */

$(() => {

  $(".show-more").on("click", function() {
    $(this).hide();
    $(".show-more-panel").removeClass("hide");
  });

})
