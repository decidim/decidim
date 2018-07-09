/* eslint-disable max-lines, id-length, no-invalid-this, no-cond-assign, no-unused-vars, max-params, no-undefined, no-sequences, multiline-ternary, no-ternary */
/* eslint prefer-reflect: ["error", { "exceptions": ["call"] }] */
/* eslint dot-location: ["error", "property"] */
/* global d3, DATACHARTS, fetchDatacharts */

// = require d3

const renderLineCharts = () => {
  // lib
  const linechart = (opts = {}) => {
    // remove any previous chart
    $(opts.container).empty()

    // parse opts
    let data = opts.data
    let title = opts.title
    let subtitle = opts.subtitle
    let container = d3.select(opts.container)
    let ratio = opts.ratio
    let xTickFormat = opts.xTickFormat
    let showTooltip = opts.tip !== "false"

    // precalculation
    // Explanation: get the inner keys foreach object outer values, flat the array, remove duplicates
    let keys = data.map((f) => f.key)

    const legendSize = 15
    const headerHeight = (keys.length * legendSize * 1.2)
    const gutter = 5

    // set the dimensions and margins of the graph
    let margin = {
      top: headerHeight + (gutter * 2),
      right: gutter * 2,
      bottom: gutter * 6,
      left: gutter * 2
    }

    let width = Number(container.node().getBoundingClientRect().width) - margin.left - margin.right
    let height = (width / ratio) - margin.top - margin.bottom

    // set the ranges
    const x = d3.scaleTime().range([0, width])
    const y = d3.scaleLinear().range([height, 0])

    // set the scales
    x.domain(d3.extent([...new Set([].concat(...data.map((f) => f.value.map((d) => d.key))))]))
    // group names
    y.domain(d3.extent([...new Set([].concat(...data.map((f) => f.value.map((d) => d.value))))]))

    // container
    let svg = container.append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)

    let upper = svg.append("g")
      .attr("transform", `translate(0,${headerHeight})`)

    // title
    upper.append("text")
      .attr("x", 0)
      .attr("y", -20)
      .attr("class", "title")
      .text(title)

    // subtitle
    upper.append("text")
      .attr("class", "subtitle")
      .text(subtitle)

    // legend
    let legend = upper.append("g")
      .attr("text-anchor", "end")
      .selectAll("g")
      .data(keys)
      .enter().append("g")
      .attr("transform", (d, i, arr) => `translate(0,${-((arr.length - 1 - i) * legendSize * 1.2) - margin.top + headerHeight})`)

    legend.append("rect")
      .attr("x", width + margin.left + margin.right - legendSize)
      .attr("width", legendSize)
      .attr("height", legendSize)
      .attr("class", (d, i) => `legend type-${i}`)

    legend.append("text")
      .attr("x", width + margin.left + margin.right - legendSize - 4)
      .attr("y", legendSize / 2)
      .attr("dy", "0.32em")
      .attr("class", "subtitle")
      .text((d) => d)

    let lower = svg.append("g")
      .attr("transform", `translate(0,${margin.top})`)

    // background
    lower.append("rect")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + gutter - headerHeight)
      .attr("class", "background")

    // main group
    let g = lower.append("g")
      .attr("transform", `translate(${margin.left},${margin.top - headerHeight})`)

    let line = d3.line()
      .curve(d3.curveBasis)
      .x((d) => x(d.key))
      .y((d) => y(d.value))

    let cat = g.selectAll("path")
      .data(data)
      .enter().append("path")
      .attr("d", (d) => line(d.value))
      .attr("class", (d) =>  `line type-${keys.indexOf(d.key)}`)

    // axis
    let xAxis = d3.axisBottom(x)
      .ticks(5)
      .tickSize(-height)
      .tickFormat(xTickFormat)
    let yAxis = d3.axisLeft(y)

    let _xAxis = (xg) => {
      xg.call(xAxis)
      xg.select(".domain").remove()
      xg.selectAll(".tick line").attr("class", "dashed")
      xg.selectAll(".tick text").attr("y", gutter + 6)
    }
    let _yAxis = (yg) => {
      yg.call(yAxis)
      yg.select(".domain").remove()
      yg.selectAll(".tick text").attr("text-anchor", "start").attr("x", 6)
    }

    g.append("g")
      .attr("class", "x axis")
      .attr("transform", `translate(0,${height})`)
      .call(_xAxis)

    g.append("g")
      .attr("class", "y axis")
      .call(_yAxis)

    // tooltip
    if (showTooltip) {
      let tooltip = d3.select("body").append("div")
        .attr("id", `${container.node().id}-tooltip`)
        .attr("class", "chart-tooltip")
        .style("opacity", 0)

      // barGroup.selectAll("rect")
      //   .on("mouseover", () => {
      //     tooltip.style("opacity", 1)
      //   })
      //   .on("mouseout", () => {
      //     tooltip.style("opacity", 0)
      //   })
      //   .on("mousemove", function(d, p, e, l, h) {
      //     // svg position relative to document
      //     let coords = {
      //       x: window.pageXOffset + container.node().getBoundingClientRect().left,
      //       y: window.pageYOffset + container.node().getBoundingClientRect().top
      //     }
      //
      //     let tooltipContent = `
      //       <div class="tooltip-content">
      //         ${d.key}: ${d.value.toLocaleString()}
      //       </div>`
      //
      //     tooltip.html(tooltipContent)
      //       .style("left", `${coords.x + (x(d.value) / 2) + margin.left}px`)
      //       .style("top", `${coords.y + y1(d.key) + y0(d.ref) + margin.top}px`)
      //   })
    }
  }

  return $(".linechart:visible").each((i, container) => {

    // Initialize dataset values
    const init = (dataset) => {
      const datasetDefault = {
        metric: "",
        title: "",
        subtitle: "",
        ratio: "",
        percent: "",
        tip: ""
      }
      return {...datasetDefault, ...dataset}
    }

    // OPTIONAL: Helper function to turn all values into percentages
    const percentage = (percent) => {
      // helper function to groupBy
      const groupBy = (arr, by) => arr.reduce((r, v, j, a, k = v[by]) => ((r[k] || (r[k] = [])).push(v), r), {})
      // get an object grouped by key
      let groupByKey = groupBy([].concat(...percent.map((f) => f.value)), "key")
      // get total sum of values by key
      for (let cat in groupByKey) {
        if (Object.prototype.hasOwnProperty.call(groupByKey, cat)) {
          groupByKey[cat] = groupByKey[cat].map((f) => f.value).reduce((a, b) => a + b)
        }
      }
      // updates every value with its respective percentage
      [].concat(...percent.map((f) => f.value)).map((item) => {
        item.value = (item.value / groupByKey[item.key]) * 100
        return item
      })

      return percent
    }

    // OPTIONAL: Helper function to add a reference to the parent
    const addRefs = (parentize) => {
      for (let x = 0; x < parentize.length; x += 1) {
        if (Object.prototype.hasOwnProperty.call(parentize[x], "value")) {
          for (let y = 0; y < parentize[x].value.length; y += 1) {
            parentize[x].value[y].ref = parentize[x].key
          }
        }
      }

      return parentize
    }

    // OPTIONAL: Helper function to preprocess the data
    const parseDates = (data) => {
      // format the data
      data.forEach((d) => {
        d.value.forEach((f) => {
          f.key = d3.isoParse(f.key)
        })

        d.value.sort((x, y) => d3.ascending(x.key, y.key))
      });

      return data
    }

    // MANDATORY: HTML must contain which metric should it display
    // If there's no data, fetch it
    if (!DATACHARTS || !DATACHARTS[container.dataset.metric]) {
      fetchDatacharts()
    }

    // Make a clone of the array of objects
    let data = DATACHARTS[container.dataset.metric].map((d) => {
      return { ...d }
    })

    if (data) {
      let config = init(container.dataset)
      let dataModified = parseDates(addRefs(data))

      if (config.percent === "true") {
        dataModified = percentage(dataModified)
        config.xTickFormat = (d) => `${d}%`
      }

      linechart({
        container: `#${container.id}`,
        title: config.title,
        subtitle: config.subtitle,
        data: dataModified,
        xTickFormat: config.xTickFormat,
        ratio: config.ratio.split(":").reduce((a, b) => a / b) || (4 / 3),
        tip: config.tip
      })
    }
  })
}
