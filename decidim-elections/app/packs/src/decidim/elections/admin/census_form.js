document.addEventListener("DOMContentLoaded", () => {
  const censusManifestSelector = document.getElementById("census-manifest-selector");

  if (censusManifestSelector) {
    censusManifestSelector.addEventListener("change", (event) => {
      const selectedManifest = event.target.value;
      const url = new URL(window.location.href);
      url.searchParams.set("manifest", selectedManifest);
      window.location.href = url.toString();
      return;
    });
  }
});
