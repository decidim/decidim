/* eslint-disable id-length, no-ternary, no-nested-ternary */
/* global d3 */
/* eslint prefer-reflect: ["error", { "exceptions": ["call"] }] */
/* eslint dot-location: ["error", "property"] */
// = require d3

$(() => {
  const areachart = (opts = {}) => {
    // parse opts
    let data = opts.data
    let title = opts.title
    let container = d3.select(opts.container)

    // set the dimensions and margins of the graph
    let width = Number(container.node().getBoundingClientRect().width)
    let height = width / (4 / 3)
    let titlePadding = width / 10

    // set the ranges
    let x = d3.scaleTime().range([0, width]);
    let y = d3.scaleLinear().range([height, 0]);

    // define the area
    let area = d3.area()
      .x((d) => x(d.key))
      .y0(height)
      .y1((d) => y(d.value));

    // define the line
    let valueline = d3.line()
      .x((d) => x(d.key))
      .y((d) => y(d.value));

    let svg = container.append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")

    // scale the range of the data
    x.domain(d3.extent(data, (d) => d.key));
    y.domain(d3.extent(data, (d) => d.value));

    // add the area
    svg.append("path")
      .data([data])
      .attr("class", "area")
      .attr("d", area);

    // add the valueline path.
    svg.append("path")
      .data([data])
      .attr("class", "line")
      .attr("d", valueline);

    // add the title group
    let g = svg.append("g")
      .attr("text-anchor", "start")
      .attr("transform", `translate(${titlePadding},${titlePadding})`)

    g.append("text")
      .attr("x", 0)
      .attr("y", 0)
      .attr("class", "title")
      .text(title)

    g.append("text")
      .attr("x", 0)
      .attr("y", titlePadding * 2)
      .attr("class", "sum")
      .text(Number(data.map((r) => r.value).reduce((a, b) => a + b, 0)).toLocaleString())
  }

  // OPTIONAL: Helper function to preprocess the data
  const parseData = (data) => {
    // format the data
    data.forEach((d) => {
      d.key = d3.isoParse(d.key)
      d.value = Number(d.value)
    });

    // order by date
    return data.sort((x, y) => d3.descending(x.key, y.key))
  }

  $(".areachart").each((i, container) => {
    // get the data
    d3.json(container.dataset.url).then((data) => {
      areachart({
        container: `#${container.id}`,
        title: container.dataset.title,
        data: parseData(data)
      })
    })
  })
});
