/* global areachart */

$(() => {
  const query = () => {
    let metricsQuery = `metrics(names: [${metrics_params.names}], space_type: "${metrics_params.space_type}", space_id: ${metrics_params.space_id}) { name history { key value } }`;
    return {query: `{ ${metricsQuery} }`};
  }

  const parameterize = (metrics) => {
    metrics_params.names = metrics.join(" ");
    metrics_params.space_type = $("#metrics #metrics-space_type").val() || null;
    metrics_params.space_id = $("#metrics #metrics-space_id").val() || null;
  }

  const fetch = (metrics) => $.post("/api", query(metrics))

  const metrics = {};
  const metrics_params = {}

  $(".metric-chart:visible").each((index, container) => {
    metrics[$(container).data("metric")] = container;
  });

  if (!$.isEmptyObject(metrics)) {
    parameterize(Object.keys(metrics))
    fetch().then((response) => {
      if(response.data) {
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
      } else if (response.errors) {
        console.log("Something wrong happened when fetching metrics:");
        $.each(response.errors, (_index, error) => {
          console.log(error.message);
        });
      }
    }).fail((err) => {
      console.log("Something wrong happened when fetching metrics: " + err.statusText);
    });
  }
});
