/* eslint-disable require-jsdoc */
// renderChart receives a chart function as argument and renders it
// Also captures change.zf.tabs event and re-renders the chart
export default function renderChart(chart) {
  chart()
  $(document).on("change.zf.tabs", () => {
    chart()
  });
}
