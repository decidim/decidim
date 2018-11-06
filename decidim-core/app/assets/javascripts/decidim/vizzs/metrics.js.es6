/* eslint-disable no-console */
/* global areachart */

$(() => {

  const metricsContainer = {};
  const metricsParams = {};

  const query = () => {
    let metricsQuery = `metrics(names: [${metricsParams.names}], space_type: "${metricsParams.spaceType}", space_id: ${metricsParams.spaceId}) { name history { key value } }`;
    return {query: `{ ${metricsQuery} }`};
  }

  const parameterize = (metrics) => {
    metricsParams.names = metrics.join(" ");
    metricsParams.spaceType = $("#metrics #metrics-space_type").val() || null;
    metricsParams.spaceId = $("#metrics #metrics-space_id").val() || null;
  }

  const fetch = (metrics) => $.post("/api", query(metrics));

  $(".metric-chart:visible").each((index, container) => {
    metricsContainer[$(container).data("metric")] = container;
  });

  if (!$.isEmptyObject(metricsContainer)) {
    parameterize(Object.keys(metricsContainer))
    fetch().then((response) => {
      if (response.data) {
        $.each(response.data.metrics, (_index, metricData) => {
          let container = metricsContainer[metricData.name];
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
        $("#metrics").remove();
      }
    }).fail((err) => {
      console.log(`Something wrong happened when fetching metrics: ${err.statusText}`);
      $("#metrics").remove();
    });
  }
});
