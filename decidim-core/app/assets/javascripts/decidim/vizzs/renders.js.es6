/* global renderAreaCharts, renderRowCharts */
$(() => {
  const render = () => {
    renderAreaCharts()
    renderRowCharts()
  }

  // init
  render()
  // only for pattern-library
  $(document).on("change.zf.tabs", () => {
    render()
  });
  $(document).on("down.zf.accordion", () => {
    render()
  });
});
