$(() => {
  const toggleBackdrop = () => {
    const progressSummaryButton = document.getElementById("progress-summary-button");
    const backdrop = document.getElementById("progress-summary-backdrop");

    if (!progressSummaryButton || !backdrop) {
      return;
    }

    const isOpen = progressSummaryButton.getAttribute("aria-expanded") === "true";

    backdrop.classList.toggle("hidden", !isOpen);
  }

  const setupBackdrop = () => {
    const progressSummaryButton = document.getElementById("progress-summary-button");
    const backdrop = document.getElementById("progress-summary-backdrop");

    if (!progressSummaryButton || !backdrop) {
      return;
    }

    progressSummaryButton.addEventListener("click", toggleBackdrop);
    backdrop.addEventListener("click", () => {
      backdrop.classList.add("hidden");
    });
  }

  toggleBackdrop();
  setupBackdrop();

  window.DecidimBudgets.toggleBackdrop = toggleBackdrop;
});
