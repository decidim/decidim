$(() => {
  const updateCensusDatasetStatus = () => {
    const $wrapper = $("#census-creating-data-wrapper");
    const updateStatusUrl = $wrapper.data("updateStatusUrl")

    if ($wrapper.length > 0) {
      $.get(updateStatusUrl);
    }
  }

  // 30 seconds
  setInterval(updateCensusDatasetStatus, 30000);
});
