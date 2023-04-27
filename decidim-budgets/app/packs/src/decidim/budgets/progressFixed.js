$(() => {
  const checkProgressPosition = () => {

    const progressRef = document.querySelectorAll("[data-progress-reference]");
    const progressFix = document.querySelectorAll("[data-progressbox-fixed]");
    let selectedProgressRef = window.matchMedia("(min-width: 768px)").matches ? progressRef[1] : progressRef[0];
    let selectedProgressFix  = window.matchMedia("(min-width: 768px)").matches ? progressFix[1] : progressFix[0]
    let progressVisibleClass = "is-progressbox-visible";

    if (!progressRef) {
      return;
    }

    let progressPosition = selectedProgressRef.getBoundingClientRect().bottom;
    if (progressPosition > 0) {
      selectedProgressFix.classList.remove(progressVisibleClass);
    } else {
      selectedProgressFix.classList.add(progressVisibleClass);
    }
  }

  window.addEventListener("scroll", checkProgressPosition);

  window.DecidimBudgets = window.DecidimBudgets || {};
  window.DecidimBudgets.checkProgressPosition = checkProgressPosition;
});
