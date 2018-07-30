/* global areachart */

$(() => {
  const query = (metric) => {
    return {query: `{ ${metric} { metric { key value } } }`};
  }

  const fetch = (metric) => $.post("api", query(metric))

  $(".metric-chart:visible").each((index, container) => {
    let metric = $(container).data("metric");
    let info = $(container).data("info");
    fetch(metric).then((response) => {
      let data = response.data[metric].metric || {};
      areachart({
        container: `#${container.id}`,
        data: data,
        title: info.title,
        objectName: info.object
      });
    })
  })
});
