((exports) => {
  const updateCensusDatasetStatus = () => {
    const $wrapper = $("#census-creating-data-wrapper");
    const updateStatusUrl = $wrapper.data("updateStatusUrl")

    if ($wrapper.length > 0) {
      $.get( updateStatusUrl );
    }
  }

  setInterval(updateCensusDatasetStatus, 60000); // 1 minute
})(window);
