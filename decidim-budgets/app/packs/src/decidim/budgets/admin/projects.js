document.addEventListener("turbo:load", () => {
  const wrapper = document.querySelector(
    "#js-bulk-actions-wrapper"
  );

  const bulkActionsContainer = wrapper.closest(
    '[data-controller~="bulk-actions"]'
  );

  if (!bulkActionsContainer) {
    return;
  }

  if (!wrapper) {
    return;
  }

  const selectedResourcesCount = () => {
    return $(".table-list .js-check-all-resources:checked").length
  }

  const selectedResourcesNotPublishedAnswerCount = () => {
    return $(".table-list [data-published-state=false] .js-check-all-resources:checked").length
  }

  const selectedResourcesCountUpdate = () => {
    const selectedResources = selectedResourcesCount();
    const selectedResourcesNotPublishedAnswer =
      selectedResourcesNotPublishedAnswerCount();

    const mergeButton = wrapper.querySelector(
      'button[data-action="merge-resources"]'
    );

    if (mergeButton) {
      mergeButton.parentElement?.classList.toggle(
        "hide",
        selectedResources < 2
      );
    }

    const publishAnswersButton = wrapper.querySelector(
      'button[data-action="publish-answers"]'
    );

    if (publishAnswersButton) {
      publishAnswersButton.parentElement?.classList.toggle(
        "hide",
        selectedResourcesNotPublishedAnswer === 0
      );
    }

    const publishAnswersCount = wrapper.querySelector(
      "#js-form-publish-answers-number"
    );

    if (publishAnswersCount) {
      publishAnswersCount.textContent =
        selectedResourcesNotPublishedAnswer;
    }
  };

  const onSelectionChange = (event) => {
    if (
      !event.target.matches(".js-check-all") &&
      !event.target.matches(".js-check-all-resources")
    ) {
      return;
    }
    // Wait for bulk-actions sync before recalculating.
    queueMicrotask(selectedResourcesCountUpdate);
  };

  bulkActionsContainer.addEventListener("change", onSelectionChange)

  selectedResourcesCountUpdate();

  document.addEventListener(
    "turbo:before-cache",
    () => {
      wrapper.removeEventListener(
        "change",
        onSelectionChange
      );
    },
    { once: true }
  );
});
