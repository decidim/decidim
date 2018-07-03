/* global d3, DATACHARTS, fetchDatacharts */
/* eslint-disable id-length, no-unused-vars, multiline-ternary, no-ternary, no-nested-ternary, no-invalid-this */
/* eslint prefer-reflect: ["error", { "exceptions": ["call"] }] */
/* eslint dot-location: ["error", "property"] */

// = require d3

const renderAreaCharts = () => {
  // lib
  const areachart = (opts = {}) => {
    // parse opts
    let data = opts.data
    let title = opts.title
    let container = d3.select(opts.container)
    let showAxis = opts.axis
    let ratio = opts.ratio
    let showTooltip = opts.tip !== "false"

    // set the dimensions and margins of the graph
    let margin = {
      top: 0,
      right: 0,
      bottom: 0,
      left: 0
    }

    let width = Number(container.node().getBoundingClientRect().width) - margin.left - margin.right
    let height = (width / ratio) - margin.top - margin.bottom
    let titlePadding = d3.min([width / 10, 32])

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
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`);

    // scale the range of the data
    x.domain(d3.extent(data, (d) => d.key));
    y.domain([0, d3.max(data, (d) => d.value)]).nice();

    // add the valueline path.
    let topLine = svg.append("path")
      .data([data])
      .attr("class", "line")
      .attr("d", valueline)

    // add the area
    svg.append("path")
      .data([data])
      .attr("class", "area")
      .attr("d", area)

    if (showTooltip) {
      // tooltip
      let circle = svg.append("circle")
        .attr("class", "circle")
        .attr("r", 6)
        .style("display", "none")

      let tooltip = d3.select("body").append("div")
        .attr("id", `${container.node().id}-tooltip`)
        .attr("class", "chart-tooltip")
        .style("opacity", 0)

      svg
        .on("mouseover", () => {
          circle.style("display", null)
          tooltip.style("opacity", 1)
        })
        .on("mouseout", () => {
          circle.style("display", "none")
          tooltip.style("opacity", 0)
        })
        .on("mousemove", function() {
          let x0 = x.invert(d3.mouse(this)[0])
          let i = d3.bisector((d) => d.key).left(data, x0, 1)
          let d0 = data[i - 1]
          let d1 = data[i]
          let d = (x0 - d0.key > d1.key - x0) ? d1 : d0

          // svg position relative to document
          let coords = {
            x: window.pageXOffset + container.node().getBoundingClientRect().left,
            y: window.pageYOffset + container.node().getBoundingClientRect().top
          }

          let tooltipContent = `
            <div class="tooltip-content">
              ${d3.timeFormat("%e %B %Y")(d.key)}<br />
              ${d.value.toLocaleString()} propuestas
            </div>`

          circle.attr("transform", `translate(${x(d.key)},${y(d.value)})`)
          tooltip.html(tooltipContent)
            .style("left", `${coords.x + x(d.key)}px`)
            .style("top", `${coords.y + y(d.value)}px`)
        })
    }

    if (showAxis) {
      let xAxis = d3.axisBottom(x)
        .ticks(d3.timeMonth)
        .tickFormat(d3.timeFormat("%b %y"))
        .tickSize(-height)
      let yAxis = d3.axisLeft(y)
        .ticks(5)
        .tickSize(8)

      let _xAxis = (g) => {
        g.call(xAxis)
        g.select(".domain").remove()
        g.selectAll(".tick line").attr("class", "dashed")
        g.selectAll(".tick text").attr("y", 6)
      }
      let _yAxis = (g) => {
        g.call(yAxis)
        g.select(".domain").remove()
        g.select(".tick:first-of-type").remove()
        g.selectAll(".tick text").attr("text-anchor", "start").attr("x", 6)
      }

      // custom X-Axis
      svg.append("g")
        .attr("transform", `translate(0,${height})`)
        .call(_xAxis);

      // custom Y-Axis
      svg.append("g")
        .call(_yAxis)

      // last circle (current value)
      let g = svg.append("g")
        .data([data])
        .attr("transform", (d) => `translate(${x(d[d.length - 1].key)},${y(d[d.length - 1].value)})`)

      g.append("circle")
        .attr("class", "circle")
        .attr("r", 8)

      g.append("text")
        .attr("class", "sum")
        .attr("text-anchor", "end")
        .attr("dx", -8 * 2)
        .text((d) => d[d.length - 1].value.toLocaleString())

    } else {
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
        .attr("dy", titlePadding * 2)
        .attr("class", "sum")
        .text(Number(data.map((r) => r.value).reduce((a, b) => a + b, 0)).toLocaleString())
    }
  }

  return $(".areachart:visible").each((i, container) => {

    // OPTIONAL: Helper function to preprocess the data
    const parseData = (data) => {
      // format the data
      data.forEach((d) => {
        d.key = d3.isoParse(d.key)
        d.value = Number(d.value)
      });

      // order by date
      return data.sort((x, y) => d3.ascending(x.key, y.key))
    }

    // OPTIONAL: Helper function to accumulates all data values
    const aggregate = (agg) => agg.map((item, index, array) => {
      if (index > 0) {
        item.value += array[index - 1].value
      }
      return item
    })

    // If there's no data, fetch it
    if (!DATACHARTS || !DATACHARTS[container.dataset.metric]) {
      fetchDatacharts()
    }

    // MANDATORY: HTML must contain which metric should it display
    let data = DATACHARTS[container.dataset.metric].map((d) => {
      return { ...d }
    })

    if (data) {
      let dataModified = aggregate(parseData(data))

      areachart({
        container: `#${container.id}`,
        title: container.dataset.title,
        data: dataModified,
        axis: (container.dataset.axis === "true") || false,
        ratio: container.dataset.ratio.split(":").reduce((a, b) => a / b) || (4 / 3),
        tip: container.dataset.tip
      })
    }
  })
}
