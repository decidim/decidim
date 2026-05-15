/* eslint-disable no-invalid-this */

document.addEventListener("turbo:load", () => {
  $("#vote_button").mouseover(function () {
    $(this).text($(this).data("replace"));
  });

  $("#vote_button").mouseout(function () {
    $(this).text($(this).data("original"));
  });
});
