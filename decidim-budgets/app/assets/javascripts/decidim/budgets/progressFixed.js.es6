$(() => {
  const checkProgressPosition = () => {
    let progressFix = document.querySelector("[data-progressbox-fixed]"),
      progressRef = document.querySelector("[data-progress-reference]"),
      progressVisibleClass = "is-progressbox-visible";

    if (!progressRef) {
      return;
    }

    let progressPosition = progressRef.getBoundingClientRect().bottom;
    if (progressPosition > 0) {
      progressFix.classList.remove(progressVisibleClass);
    } else {
      progressFix.classList.add(progressVisibleClass);
    }
  }

  window.addEventListener("scroll", checkProgressPosition);

  window.DecidimBudgets = window.DecidimBudgets || {};
  window.DecidimBudgets.checkProgressPosition = checkProgressPosition;
});
