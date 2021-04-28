/* eslint-disable no-invalid-this */

$(() => {
  $(".vote-button-caption").mouseover(function () {
    const replaceText = $(this).data("replace");

    if (replaceText) {
      $(this).text(replaceText);
    }
  });

  $(".vote-button-caption").mouseout(function () {
    const originalText = $(this).data("original");

    if (originalText) {
      $(this).text(originalText);
    }
  });
})
