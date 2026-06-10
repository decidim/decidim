/* eslint-disable no-invalid-this */

document.addEventListener("turbo:load", () => {
  $("#vote_button").on("mouseover", function () {
    $(this).text($(this).data("replace"));
  });

  $("#vote_button").on("mouseout", function () {
    $(this).text($(this).data("original"));
  });
});
