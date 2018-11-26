/* global d3 */
/* eslint-disable id-length, no-undefined, no-unused-vars, multiline-ternary, no-ternary, no-nested-ternary, no-invalid-this */
/* eslint prefer-reflect: ["error", { "exceptions": ["call"] }] */
/* eslint dot-location: ["error", "property"] */

// = require d3

// lib
const areachart = (opts = {}) => {

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

  // parse opts
  let data = parseData(opts.data)
  let title = opts.title
  let objectName = opts.objectName || ""
  let container = d3.select(opts.container)
  let showAxis = opts.axis || false
  let ratio = (opts.ratio || "").split(":").reduce((a, b) => a / b) || (4 / 3)
  let showTooltip = Object.is(opts.tip, undefined) ? true : opts.tip
  let cumulative = opts.agg || false

  if (cumulative) {
    data = aggregate(data)
  }

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
            ${d.value.toLocaleString()} ${objectName}
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

    let titleLines = 0

    if (title.length) {
      g.append("text")
        .attr("x", 0)
        .attr("y", 0)
        .attr("class", "title")
        .text(title)
        .call(function(fulltext, wrapwidth, start = 0) {
          fulltext.each(function() {
            let text = d3.select(this)
            let word = ""
            let words = text.text().split(/\s+/).reverse()
            let line = []
            let lineNumber = 0
            let lineHeight = 1.1
            let _x = text.attr("x")
            let _y = text.attr("y")
            let dy = 0
            let tspan = text.text(null)
              .append("tspan")
              .attr("x", _x)
              .attr("y", _y)
              .attr("dy", `${dy}em`)

            /* eslint-disable no-cond-assign, no-plusplus */
            while (word = words.pop()) {
              line.push(word);
              tspan.text(line.join(" "));
              if (tspan.node().getComputedTextLength() > wrapwidth) {
                line.pop()
                tspan.text(line.join(" "))
                line = [word]
                tspan = text.append("tspan")
                  .attr("x", _x)
                  .attr("y", _y)
                  .attr("dy", `${(++lineNumber * lineHeight) + dy}em`)
                  .text(word);
              }
            }

            titleLines = lineNumber * lineHeight
          });
        }, width - (titlePadding * 2))
    }

    let fontSize = parseFloat(getComputedStyle(g.node()).fontSize);

    g.append("text")
      .attr("x", 0)
      .attr("dy", title.length ? (titlePadding * 2) + (titleLines * fontSize) : (titlePadding * 1.25))
      .attr("class", "sum")
      .text(data[data.length - 1].value.toLocaleString())
  }
}
