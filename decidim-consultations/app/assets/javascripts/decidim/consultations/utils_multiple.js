/* eslint-disable no-invalid-this, no-undefined */

$(function () {
  var $remainingVotesCount = $('#remaining-votes-count');
  $('form .multiple_votes_form input[type="checkbox"]').on('change', function() {
    var max = parseInt($remainingVotesCount.text(), 10);
    if($(this).is(':checked')) max--;
    else max++;
    if(max < 0) {
      $(this).attr('checked', false);
      return false;
    }
    $remainingVotesCount.text(max);
  });
});
