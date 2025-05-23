document.addEventListener("DOMContentLoaded", () => {
  const externalRadio = document.getElementById("csv_radio_button");
  const internalRadio = document.getElementById("permissions_radio_button");

  const externalBlock = document.getElementById("external_type");
  const internalBlock = document.getElementById("internal_type");

  const submitButton = document.querySelector(".main-tabs-menu__cta-button");

  const toggleCensusUI = () => {
    if (externalRadio?.checked) {
      externalBlock?.classList.remove("hide");
      internalBlock?.classList.add("hide");
      submitButton?.setAttribute("form", "csv-census-form");
    } else if (internalRadio?.checked) {
      internalBlock?.classList.remove("hide");
      externalBlock?.classList.add("hide");
      submitButton?.setAttribute("form", "internal-census-form");
    }
  };

  externalRadio?.addEventListener("change", toggleCensusUI);
  internalRadio?.addEventListener("change", toggleCensusUI);

  toggleCensusUI();
});
