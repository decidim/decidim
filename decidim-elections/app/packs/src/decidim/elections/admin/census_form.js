document.addEventListener("DOMContentLoaded", () => {
  const externalRadio = document.getElementById("csv_radio_button");
  const internalRadio = document.getElementById("permissions_radio_button");

  const externalBlock = document.getElementById("external_type");
  const internalBlock = document.getElementById("internal_type");

  const ctaLink = document.querySelector(".main-tabs-menu__cta-button");

  const isInternalCensus = ctaLink?.dataset.internalCensus === "true";
  const isExternalCensus = ctaLink?.dataset.externalCensus === "true";
  const isCensusReady   = ctaLink?.dataset.censusReady === "true";

  const toggleCensusUI = () => {
    if (externalRadio?.checked) {
      externalBlock?.classList.remove("hide");
      internalBlock?.classList.add("hide");
      if (isInternalCensus || !isCensusReady) {
        ctaLink?.classList.add("hide");
      } else {
        ctaLink?.classList.remove("hide");
      }
    } else if (internalRadio?.checked) {
      internalBlock?.classList.remove("hide");
      externalBlock?.classList.add("hide");
      if (isExternalCensus) {
        ctaLink?.classList.add("hide");
      } else {
        ctaLink?.classList.remove("hide");
      }
    }
  };

  externalRadio?.addEventListener("change", toggleCensusUI);
  internalRadio?.addEventListener("change", toggleCensusUI);

  toggleCensusUI();
});
