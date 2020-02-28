// = require_self
$(document).ready(function () {
  let selectedProposalsCount = function() {
    return $('.table-list .js-check-all-proposal:checked').length
  }

  let selectedProposalsNotPublishedAnswerCount = function() {
    return $('.table-list [data-published-state=false] .js-check-all-proposal:checked').length
  }

  window.selectedProposalsCountUpdate = function() {
    const selectedProposals = selectedProposalsCount();
    const selectedProposalsNotPublishedAnswer = selectedProposalsNotPublishedAnswerCount();
    if(selectedProposals == 0){
      $("#js-selected-proposals-count").text("")
    } else {
      $("#js-selected-proposals-count").text(selectedProposals);
    }

    if(selectedProposals >= 2) {
      $('button[data-action="merge-proposals"]').parent().show();
    } else {
      $('button[data-action="merge-proposals"]').parent().hide();
    }

    if(selectedProposalsNotPublishedAnswer > 0) {
      $('button[data-action="publish-answers"]').parent().show();
      $('#js-form-publish-answers-number').text(selectedProposalsNotPublishedAnswer);
    } else {
      $('button[data-action="publish-answers"]').parent().hide();
    }
  }

  let showBulkActionsButton = function() {
    if(selectedProposalsCount() > 0){
      $("#js-bulk-actions-button").removeClass('hide');
    }
  }

  window.hideBulkActionsButton = function(force = false) {
    if(selectedProposalsCount() == 0 || force == true){
      $("#js-bulk-actions-button").addClass('hide');
      $("#js-bulk-actions-dropdown").removeClass('is-open');
    }
  }

  window.showOtherActionsButtons = function() {
    $("#js-other-actions-wrapper").removeClass('hide');
  }

  window.hideOtherActionsButtons = function() {
    $("#js-other-actions-wrapper").addClass('hide');
  }

  window.hideBulkActionForms = function() {
    $(".js-bulk-action-form").addClass('hide');
  }

  if ($('.js-bulk-action-form').length) {
    window.hideBulkActionForms();
    $("#js-bulk-actions-button").addClass('hide');

    $("#js-bulk-actions-dropdown ul li button").click(function(e){
      e.preventDefault();
      let action = $(e.target).data("action");

      if(action) {
        $(`#js-form-${action}`).submit(function(){
          $('.layout-content > .callout-wrapper').html("");
        })

        $(`#js-${action}-actions`).removeClass('hide');
        window.hideBulkActionsButton(true);
        window.hideOtherActionsButtons();
      }
    })

    // select all checkboxes
    $(".js-check-all").change(function() {
      $(".js-check-all-proposal").prop('checked', $(this).prop("checked"));

      if ($(this).prop("checked")) {
        $(".js-check-all-proposal").closest('tr').addClass('selected');
        showBulkActionsButton();
      } else {
        $(".js-check-all-proposal").closest('tr').removeClass('selected');
        window.hideBulkActionsButton();
      }

      selectedProposalsCountUpdate();
    });

    // proposal checkbox change
    $('.table-list').on('change', '.js-check-all-proposal', function (e) {
      let proposal_id = $(this).val()
      let checked = $(this).prop("checked")

      // uncheck "select all", if one of the listed checkbox item is unchecked
      if ($(this).prop("checked") === false) {
        $(".js-check-all").prop('checked', false);
      }
      // check "select all" if all checkbox proposals are checked
      if ($('.js-check-all-proposal:checked').length === $('.js-check-all-proposal').length) {
        $(".js-check-all").prop('checked', true);
        showBulkActionsButton();
      }

      if ($(this).prop("checked")) {
        showBulkActionsButton();
        $(this).closest('tr').addClass('selected');
      } else {
        window.hideBulkActionsButton();
        $(this).closest('tr').removeClass('selected');
      }

      if ($('.js-check-all-proposal:checked').length === 0) {
        window.hideBulkActionsButton();
      }

      $('.js-bulk-action-form').find(".js-proposal-id-"+proposal_id).prop('checked', checked);
      selectedProposalsCountUpdate();
    });

    $('.js-cancel-bulk-action').on('click', function (e) {
      window.hideBulkActionForms()
      showBulkActionsButton();
      showOtherActionsButtons();
    });
  }
});
