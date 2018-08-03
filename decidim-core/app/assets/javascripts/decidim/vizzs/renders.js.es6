((exports) => {
  const RenderChart = (chart) => {
    chart()
    $(document).on("change.zf.tabs", () => {
      chart()
    });
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.Visualizations = RenderChart;
})(window)
