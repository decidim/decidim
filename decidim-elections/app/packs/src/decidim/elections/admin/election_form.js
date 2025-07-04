document.addEventListener("DOMContentLoaded", () => {
  const manualStart = document.getElementById("election_manual_start");
  const datepickerRow = document.querySelector(".election_start_time");
  const availabilityRadios = document.querySelectorAll(
    'input[name="election[results_availability]"]'
  );
  const currentAvailability = () => Array.from(availabilityRadios).find(radio => radio.checked);

  if (!manualStart || !datepickerRow || availabilityRadios.length === 0) {
    return;
  }

  const toggleManualStart = () => {
    if (currentAvailability()?.value === "per_question") {
      manualStart.checked = true;
    }
    if (manualStart.checked) {
      datepickerRow.style.display = "none";
    } else {
      datepickerRow.style.display = "";
    }
  };

  const setManualStart = () => {
    if (currentAvailability()?.value === "per_question") {
      manualStart.checked = true;
      toggleManualStart();
    }
  };

  manualStart.addEventListener("change", toggleManualStart);

  availabilityRadios.forEach((radio) => {
    radio.addEventListener("change", setManualStart);
  });

  setManualStart();
});
