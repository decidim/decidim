/* global renderAreaCharts */
$(() => {
  // init
  renderAreaCharts()
  // only for pattern-library
  $(document).on("change.zf.tabs", () => {
    renderAreaCharts()
  });
});
