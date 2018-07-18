/* eslint-disable no-unused-vars */

$(() => {
  const fetch = (metric) => $.post("api", query(metric))

  const query = (metric) => {
    return {query: `{ ${metric} { metric { key value } } }`};
  }

  $(".metric-chart:visible").each((i, container) => {
    let metric = $(container).data("metric");
    fetch(metric).then((response) => {
      areachart({
        container: `#${container.id}`,
        data: response.data[metric].metric,
        title: metric
      });
    })
  })
});
