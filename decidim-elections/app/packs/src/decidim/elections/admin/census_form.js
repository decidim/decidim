document.addEventListener("DOMContentLoaded", () => {
  const censusForm = document.querySelector(".census-form");
  if (!censusForm) {
    return;
  }

  const externalRadio = document.getElementById("csv_radio_button");
  const internalRadio = document.getElementById("permissions_radio_button");

  const externalBlock = document.getElementById("external_type");
  const internalBlock = document.getElementById("internal_type");

  const ctaLink = document.querySelector(".main-tabs-menu__cta-button");
  const isCensusReady   = ctaLink?.dataset.censusReady === "true";

  const toggleCensusUI = () => {
    if (externalRadio?.checked) {
      externalBlock?.classList.remove("hide");
      internalBlock?.classList.add("hide");
    } else if (internalRadio?.checked) {
      internalBlock?.classList.remove("hide");
      externalBlock?.classList.add("hide");
    }

    if (isCensusReady) {
      ctaLink?.classList.remove("hide");
    } else {
      ctaLink?.classList.add("hide");
    }
  };

  externalRadio?.addEventListener("change", toggleCensusUI);
  internalRadio?.addEventListener("change", toggleCensusUI);

  toggleCensusUI();
});
