/* eslint-disable no-unused-vars */

// Outside of the closure to make it public
let DATACHARTS = null;

const fetchDatacharts = () => {

  const metrics = [{
    key: "NAME_TO_BE_IN_THE_HTML-1",
    query: "GRAPHQL_QUERY-1"
  }, {
    key: "NAME_TO_BE_IN_THE_HTML-2",
    query: "GRAPHQL_QUERY-2"
  }]

  const fetch = (query) => $.post("<-- GRAPHQL_URL -->", query)

  const promises = metrics.map((metric) => fetch(metric.query).then((response) => {
    DATACHARTS[metric.key] = response

    return DATACHARTS
  }))

  Promise.all(promises).then(() => DATACHARTS)

}
