$(() => {
  const checkProgressPosition = () => {

    let progressRef
    let progressFix
    let progressVisibleClass = "is-progressbox-visible";
    if(window.matchMedia('(min-width: 768px)').matches) {
      progressFix = document.querySelector("[data-progressbox-fixed]");
      progressRef = document.querySelector("[data-progress-reference]");
    } else {
      progressFix = document.querySelector("[data-progressbox-fixed-responsive]");
      progressRef = document.querySelector("[data-progress-reference-responsive]");
    }

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
