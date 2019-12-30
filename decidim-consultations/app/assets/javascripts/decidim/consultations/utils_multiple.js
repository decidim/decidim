/* eslint-disable no-invalid-this, no-undefined */

$(document).ready(function () {
  let $remainingVotesCount = $("#remaining-votes-count");
  $('form .multiple_votes_form input[type="checkbox"]').on("change", function(event) {
    let max = parseInt($remainingVotesCount.text(), 10);
    if ($(this).is(":checked")) {
      max -= 1;
    }
    else {
      max += 1;
    }
    if (max < 0) {
      $(this).prop("checked", false);
      event.preventDefault();
    }
    else {
      $remainingVotesCount.text(max);
    }
  });
});
