/* eslint-disable require-jsdoc, no-console */

import areachart from "src/decidim/vizzs/areachart"

$(() => {

  const metricsData = {};
  const metricsContainer = {};
  const metricsParams = {};

  const query = () => {
    let metricsQuery = `metrics(names: ${metricsParams.names}, space_type: "${metricsParams.spaceType}", space_id: ${metricsParams.spaceId}) { name history { key value } }`;
    return {query: `{ ${metricsQuery} }`};
  }

  const parameterize = (metrics) => {
    metricsParams.names = JSON.stringify(metrics || []);
    metricsParams.spaceType = $("#metrics #metrics-space_type").val() || null;
    metricsParams.spaceId = $("#metrics #metrics-space_id").val() || null;
  }

  const fetch = (metrics) => $.post("/api", query(metrics));

  const downloadMetricData = (event) => {
    event.preventDefault();
    let metricName = $(event.target).parents(".metric-downloader").data("metric");
    let csvContent = "data:text/csv;charset=utf-8,";

    csvContent += "key,value\r\n";
    metricsData[metricName].forEach((metricData)  => {
      csvContent += `${metricData.key},${metricData.value}\r\n`;
    });

    // Required for FF
    let link = document.createElement("a");
    link.setAttribute("href", encodeURI(csvContent));
    link.setAttribute("download", `${metricName}_metric_data.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  $(".metric-chart:visible").each((_index, container) => {
    metricsContainer[$(container).data("metric")] = container;
  });
  $(".metric-downloader").each((_index, container) => {
    container.onclick = downloadMetricData;
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
          metricsData[metricData.name] = $.extend(true, [], metricData.history);
          areachart({
            container: `#${container.id}`,
            data: metricData.history,
            title: info.title,
            objectName: info.object,
            ...$(container).data()
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
