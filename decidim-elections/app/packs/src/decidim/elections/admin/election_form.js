document.addEventListener("DOMContentLoaded", () => {
  const manualStart = document.getElementById("election_manual_start");
  const datepickerRow = document.querySelector(".election_start_time");
  const availabilityRadios = document.querySelectorAll(
    'input[name="election[results_availability]"]'
  );

  if (!manualStart || !datepickerRow || availabilityRadios.length === 0) {
    return;
  }

  const toggleVisibility = () => {
    if (manualStart.checked) {
      datepickerRow.style.display = "none";
    } else {
      datepickerRow.style.display = "";
    }
  };

  const syncManualStartWithAvailability = () => {
    const selected = document.querySelector(
      'input[name="election[results_availability]"]:checked'
    );
    if (selected?.value === "per_question") {
      manualStart.checked = true;
      toggleVisibility();
    }
  };

  manualStart.addEventListener("change", toggleVisibility);
  toggleVisibility();

  availabilityRadios.forEach((radio) => {
    radio.addEventListener("change", syncManualStartWithAvailability);
  });

  // при инициализации — тоже синхронизируем
  syncManualStartWithAvailability();
});
