/* global renderAreaChart */
$(() => {
  // init
  renderAreaChart()
  // only for pattern-library
  $(document).on("change.zf.tabs", () => {
    renderAreaChart()
  });
});
