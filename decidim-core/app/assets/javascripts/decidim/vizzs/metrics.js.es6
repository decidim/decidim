/* global areachart */

$(() => {
  const query = (metrics) => {
    let metricsQuery = `metrics(names: [${metrics.join(" ")}]) { name history { key value } }`;
    return {query: `{ ${metricsQuery} }`};
  }

  const fetch = (metrics) => $.post("api", query(metrics))

  const metrics = {};

  $(".metric-chart:visible").each((index, container) => {
    metrics[$(container).data("metric")] = container;
  });

  if (!$.isEmptyObject(metrics)) {
    fetch(Object.keys(metrics)).then((response) => {
      $.each(response.data.metrics, (_index, metricData) => {
        let container = metrics[metricData.name];
        if (metricData.history.length === 0) {
          $(container).remove();
          return;
        }
        let info = $(container).data("info");

        areachart({
          container: `#${container.id}`,
          data: metricData.history,
          title: info.title,
          objectName: info.object
        });
      });
    });
  }
});
