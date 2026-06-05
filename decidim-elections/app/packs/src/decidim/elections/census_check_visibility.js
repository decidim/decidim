document.addEventListener("DOMContentLoaded", () => {
  const censusCheckButton = document.querySelector("[data-census-check-button]");

  if (!censusCheckButton) {
    return;
  }

  const url = censusCheckButton.dataset.censusCheckUrl;

  if (!url) {
    return;
  }

  const explanation = document.querySelector("[data-census-check-explanation]");

  const toggleVisibility = (show) => {
    censusCheckButton.classList.toggle("hidden", !show);
    if (explanation) {
      explanation.classList.toggle("hidden", !show);
    }
  };

  const updateVisibility = async () => {
    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      });

      if (!response.ok) {
        return;
      }

      const data = await response.json();
      const shouldShow = data.allow_census_check_before_start && data.census_ready && data.scheduled;

      toggleVisibility(shouldShow);

      if (data.scheduled) {
        setTimeout(updateVisibility, 4000);
      }
    } catch {
      setTimeout(updateVisibility, 4000);
    }
  };

  updateVisibility();
});
