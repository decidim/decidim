$(() => {
  const selectedProjectsCount = function() {
    return $(".table-list .js-check-all-project:checked").length
  }

  const selectedProjectsNotPublishedAnswerCount = function() {
    return $(".table-list [data-published-state=false] .js-check-all-project:checked").length
  }

  const selectedProjectsCountUpdate = function() {
    const selectedProjects = selectedProjectsCount();
    const selectedProjectsNotPublishedAnswer = selectedProjectsNotPublishedAnswerCount();
    if (selectedProjects === 0) {
      $("#js-selected-projects-count").text("")
    } else {
      $("#js-selected-projects-count").text(selectedProjects);
    }

    if (selectedProjects >= 2) {
      $('button[data-action="merge-projects"]').parent().show();
    } else {
      $('button[data-action="merge-projects"]').parent().hide();
    }

    if (selectedProjectsNotPublishedAnswer > 0) {
      $('button[data-action="publish-answers"]').parent().show();
      $("#js-form-publish-answers-number").text(selectedProjectsNotPublishedAnswer);
    } else {
      $('button[data-action="publish-answers"]').parent().hide();
    }
  }

  const showBulkActionsButton = function() {
    if (selectedProjectsCount() > 0) {
      $("#js-bulk-actions-button").removeClass("hide");
    }
  }

  const hideBulkActionsButton = function(force = false) {
    if (selectedProjectsCount() === 0 || force === true) {
      $("#js-bulk-actions-button").addClass("hide");
      $("#js-bulk-actions-dropdown").removeClass("is-open");
    }
  }

  const showOtherActionsButtons = function() {
    $("#js-other-actions-wrapper").removeClass("hide");
  }

  const hideOtherActionsButtons = function() {
    $("#js-other-actions-wrapper").addClass("hide");
  }

  const hideBulkActionForms = function() {
    $(".js-bulk-action-form").addClass("hide");
  }

  // Expose functions to make them avaialble in .js.erb templates
  window.selectedProjectsCount = selectedProjectsCount;
  window.selectedProjectsNotPublishedAnswerCount = selectedProjectsNotPublishedAnswerCount;
  window.selectedProjectsCountUpdate = selectedProjectsCountUpdate;
  window.showBulkActionsButton = showBulkActionsButton;
  window.hideBulkActionsButton = hideBulkActionsButton;
  window.showOtherActionsButtons = showOtherActionsButtons;
  window.hideOtherActionsButtons = hideOtherActionsButtons;
  window.hideBulkActionForms = hideBulkActionForms;

  if ($(".js-bulk-action-form").length) {
    hideBulkActionForms();
    $("#js-bulk-actions-button").addClass("hide");

    $("#js-bulk-actions-dropdown ul li button").click(function(e) {
      e.preventDefault();
      let action = $(e.target).data("action");

      if (action) {
        $(`#js-form-${action}`).on("submit", function() {
          $(".layout-content > .callout-wrapper").html("");
        })

        $(`#js-${action}-actions`).removeClass("hide");
        hideBulkActionsButton(true);
        hideOtherActionsButtons();
      }
    })

    // select all checkboxes
    $(".js-check-all").on("change", function() {
      $(".js-check-all-project").prop("checked", $(this).prop("checked"));

      if ($(this).prop("checked")) {
        $(".js-check-all-project").closest("tr").addClass("selected");
        showBulkActionsButton();
      } else {
        $(".js-check-all-project").closest("tr").removeClass("selected");
        hideBulkActionsButton();
      }

      selectedProjectsCountUpdate();
    });

    // project checkbox change
    $(".table-list").on("change", ".js-check-all-project", function (e) {
      let projectId = $(this).val()
      let checked = $(this).prop("checked")

      // uncheck "select all", if one of the listed checkbox item is unchecked
      if ($(this).prop("checked") === false) {
        $(".js-check-all").prop("checked", false);
      }
      // check "select all" if all checkbox projects are checked
      if ($(".js-check-all-project:checked").length === $(".js-check-all-project").length) {
        $(".js-check-all").prop("checked", true);
        showBulkActionsButton();
      }

      if ($(this).prop("checked")) {
        showBulkActionsButton();
        $(this).closest("tr").addClass("selected");
      } else {
        hideBulkActionsButton();
        $(this).closest("tr").removeClass("selected");
      }

      if ($(".js-check-all-project:checked").length === 0) {
        hideBulkActionsButton();
      }

      $(".js-bulk-action-form").find(`.js-project-id-${projectId}`).prop("checked", checked);
      selectedProjectsCountUpdate();
    });

    $(".js-cancel-bulk-action").on("click", function (e) {
      hideBulkActionForms()
      showBulkActionsButton();
      showOtherActionsButtons();
    });
  }
});
