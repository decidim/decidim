document.addEventListener("DOMContentLoaded", () => {
  const manualStart = document.getElementById("election_manual_start");
  const datepickerRow = document.querySelector(".election_start_time");

  if (!manualStart || !datepickerRow) return;

  const toggleVisibility = () => {
    if (manualStart.checked) {
      datepickerRow.style.display = "none";
    } else {
      datepickerRow.style.display = "";
    }
  };

  manualStart.addEventListener("change", toggleVisibility);
  toggleVisibility();
});
