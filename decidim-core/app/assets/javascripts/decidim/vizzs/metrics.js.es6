/* global areachart */

$(() => {
  const query = (metrics) => {
    let arr = $.map(metrics, (metric) => {
      return ` ${metric} { metric { key value } }`;
    });
    return {query: `{ ${arr.join(" ")} }`};
  }

  const fetch = (metrics) => $.post("api", query(metrics))

  const metrics = {};

  $(".metric-chart:visible").each((index, container) => {
    metrics[$(container).data("metric")] = container;
  });

  if (!$.isEmptyObject(metrics)) {
    fetch(Object.keys(metrics)).then((response) => {
      $.each(response.data, (metricKey, metricData) => {
        let container = metrics[metricKey];
        if (metricData.metric.length === 0) {
          $(container).remove();
          return;
        }
        let info = $(container).data("info");

        areachart({
          container: `#${container.id}`,
          data: metricData.metric,
          title: info.title,
          objectName: info.object
        });
      });
    });
  }
});
