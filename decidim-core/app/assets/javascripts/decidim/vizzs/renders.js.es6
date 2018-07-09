/* global renderAreaCharts, renderRowCharts, renderLineCharts */
$(() => {
  const render = () => {
    renderAreaCharts()
    renderRowCharts()
    renderLineCharts()
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
