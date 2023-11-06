$(() => {
  const checkProgressPosition = () => {

    const progressRef = document.querySelectorAll("[data-progress-reference]");
    if (progressRef.length) {
      const progressFix = document.querySelectorAll("[data-progressbox-fixed]");

      let selectedProgressRef = "";
      let selectedProgressFix = "";
      const progressVisibleClass = "is-progressbox-visible";

      if (window.matchMedia("(min-width: 768px)").matches) {
        selectedProgressRef = progressRef[1];
        selectedProgressFix = progressFix[1];
      } else {
        selectedProgressRef = progressRef[0];
        selectedProgressFix = progressFix[0];
      }

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
  }

  window.addEventListener("scroll", checkProgressPosition);

  window.DecidimBudgets = window.DecidimBudgets || {};
  window.DecidimBudgets.checkProgressPosition = checkProgressPosition;
});
