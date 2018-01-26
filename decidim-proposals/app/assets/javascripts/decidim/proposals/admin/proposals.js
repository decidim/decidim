// = require_self

let selectedProposalsCount = function() {
  return $("#js-recategorize-proposals-count").text($('.js-check-all-proposal:checked').length);
}

if ($('#js-form-recategorize-proposals').length) {
  /* eslint-disable no-invalid-this */

  $("#js-recategorize-proposals-actions").addClass('invisible');

  // select all checkboxes
  $(".js-check-all").change(function() {
    $(".js-check-all-proposal").prop('checked', $(this).prop("checked"));

    if ($(this).prop("checked")) {
      $("#js-recategorize-proposals-actions").removeClass('invisible');
    } else {
      $("#js-recategorize-proposals-actions").addClass('invisible');
    }

    selectedProposalsCount()
  });

  // proposal checkbox change
  $('.js-check-all-proposal').change(function() {
    // uncheck "select all", if one of the listed checkbox item is unchecked
    if ($(this).prop("checked") === false) {
      $(".js-check-all").prop('checked', false);
    }
    // check "select all" if all checkbox proposals are checked
    if ($('.js-check-all-proposal:checked').length === $('.js-check-all-proposal').length) {
      $(".js-check-all").prop('checked', true);
      $("#js-recategorize-proposals-actions").removeClass('invisible');
    }

    if ($(this).prop("checked")) {
      $("#js-recategorize-proposals-actions").removeClass('invisible');
    }

    if ($('.js-check-all-proposal:checked').length === 0) {
      $("#js-recategorize-proposals-actions").addClass('invisible');
    }

    selectedProposalsCount()
  });
}
