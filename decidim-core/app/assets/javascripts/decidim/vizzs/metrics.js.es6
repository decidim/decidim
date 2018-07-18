/* eslint-disable no-unused-vars */

$(() => {
  const fetch = (metric) => $.post("api", query(metric))

  const query = (metric) => {
    return {query: `{ ${metric} { metric { key value } } }`};
  }

  $(".metric-chart:visible").each((i, container) => {
    let metric = $(container).data("metric");
    let info = $(container).data("info");
    fetch(metric).then((response) => {
      let data = response.data[metric].metric || {};
      areachart({
        container: `#${container.id}`,
        data: data,
        title: info.title,
        object_name: info.object
      });
    })
  })
});
