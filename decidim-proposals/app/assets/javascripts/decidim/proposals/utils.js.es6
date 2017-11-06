/* eslint-disable no-invalid-this */

(() => {
  $("#vote_button").mouseover(function () {
    $(this).text($(this).data('replace'));
  });

  $("#vote_button").mouseout(function () {
    $(this).text($(this).data('original'));
  });
})(this);
