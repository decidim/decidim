/* global d3, DATACHARTS, fetchDatacharts */
/* eslint-disable id-length, no-unused-vars, multiline-ternary, no-ternary, no-nested-ternary, no-invalid-this */
/* eslint prefer-reflect: ["error", { "exceptions": ["call"] }] */
/* eslint dot-location: ["error", "property"] */

// = require d3

const renderRowCharts = () => {
  // helper https://www.sitepoint.com/javascript-generate-lighter-darker-color/
  const colorLuminance = (_hex, _lum) => {
    // validate hex string
    let hex = String(_hex).replace(/[^0-9a-f]/gi, "")
    if (hex.length < 6) {
      hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2]
    }
    let lum = _lum || 0

    // convert to decimal and change luminosity
    let rgb = "#"
    let c = 0

    for (let i = 0; i < 3; i += 1) {
      c = parseInt(hex.substr(i * 2, 2), 16)
      c = Math.round(Math.min(Math.max(0, c + (c * lum)), 255)).toString(16)
      rgb += (`00${c}`).substr(c.length)
    }

    return rgb;
  }

  // lib
  const rowchart = (opts = {}) => {
    // parse opts
    let data = opts.data
    let title = opts.title
    let subtitle = opts.subtitle
    let container = d3.select(opts.container)
    let ratio = opts.ratio
    let showTooltip = opts.tip !== "false"
    let baseColor = opts.color
    let legendSize = 15

    // precalculation
    // Explanation: get the inner values foreach object outer values, flat the array, remove duplicates
    let maxValue = d3.max([...new Set([].concat(...data.map((f) => f.value.map((d) => d.value))))])
    // Explanation: get the inner keys foreach object outer values, flat the array, remove duplicates
    let keys = [...new Set([].concat(...data.map((f) => f.value.map((d) => d.key))))]

    const headerHeight = (keys.length * legendSize * 1.2)
    const gutter = 5

    // set the dimensions and margins of the graph
    let margin = {
      top: headerHeight + (gutter * 2),
      right: gutter * 2,
      bottom: gutter * 6,
      left: Number(container.node().getBoundingClientRect().width) / 4
    }

    let width = Number(container.node().getBoundingClientRect().width) - margin.left - margin.right
    let height = (width / ratio) - margin.top - margin.bottom

    // set the ranges
    const x = d3.scaleLinear().rangeRound([0, width])
    const y0 = d3.scaleBand().rangeRound([height, 0]).paddingInner(0.1)
    const y1 = d3.scaleBand().padding(0.05)

    // set the scales
    x.domain([0, maxValue]).nice()
    // group names
    y0.domain(data.map((d) => d.key))
    // individual values for each group
    y1.domain(keys).rangeRound([0, y0.bandwidth()])

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
      .data(keys.slice().reverse())
      .enter().append("g")
      .attr("transform", (d, i) => `translate(0,${-(i * legendSize * 1.2) - margin.top + headerHeight})`)

    legend.append("rect")
      .attr("x", width + margin.left + margin.right - legendSize)
      .attr("width", legendSize)
      .attr("height", legendSize)
      .attr("fill", baseColor)

    legend.append("text")
      .attr("x", width + margin.left + margin.right - legendSize - 4)
      .attr("y", legendSize / 2)
      .attr("dy", "0.32em")
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

    // axis
    let xAxis = d3.axisBottom(x)
      .ticks(5)
      .tickSize(-height)
    let yAxis = d3.axisLeft(y0)

    let _xAxis = (xg) => {
      xg.call(xAxis)
      xg.select(".domain").remove()
      xg.selectAll(".tick line").attr("class", "dashed")
      xg.selectAll(".tick text").attr("y", gutter + 6)
    }
    let _yAxis = (yg) => {
      yg.call(yAxis)
      yg.select(".domain").remove()
      yg.selectAll(".tick line").remove()
      yg.selectAll(".tick text")
        .attr("class", "text-large")
    }

    g.append("g")
      .attr("class", "x axis")
      .attr("transform", `translate(0,${height})`)
      .call(_xAxis)

    g.append("g")
      .attr("class", "y axis")
      .call(_yAxis)

    // bars
    let barGroup = g.append("g")
      .selectAll("g")
      .data(data)
      .enter().append("g")
      .attr("class", "group")
      .attr("transform", (d) => `translate(0,${y0(d.key)})`)

    barGroup.selectAll("rect")
      .data((d) => d.value)
      .enter().append("rect")
      .attr("y", (d) => y1(d.key))
      .attr("height", y1.bandwidth())
      .attr("class", (d, i) => `type-${i}`)
      .transition()
      .duration(500)
      .attr("width", (d) => x(d.value))
      .attr("fill", (d, i) => {
        // if odd, baseColor darker (negative); if even, baseColor lighter (positive)
        return (i % 2 === 0) ? colorLuminance(baseColor, i * 0.25) : colorLuminance(baseColor, -i * 0.25)
      })
  }

  return $(".rowchart:visible").each((i, container) => {

    // Initialize dataset values
    const init = (dataset) => {
      const datasetDefault = {
        metric: "",
        title: "",
        subtitle: "",
        ratio: "",
        color: "",
        tip: ""
      }
      return {...datasetDefault, ...dataset}
    }

    // OPTIONAL: Helper function to preprocess the data
    const parseData = (data) => {
      // format the data
      data.forEach((d) => {
        d.key = d3.isoParse(d.key)
        d.value = Number(d.value)
      })

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
      // let dataModified = aggregate(parseData(data))

      let config = init(container.dataset)
      let colors = ["238ff7", "57d685", "fa6c96", "fabc6c"]

      rowchart({
        container: `#${container.id}`,
        title: config.title,
        subtitle: config.subtitle,
        data: data,
        // data: dataModified,
        ratio: config.ratio.split(":").reduce((a, b) => a / b) || (4 / 3),
        color: config.color || colors[Math.floor(Math.random() * colors.length)],
        tip: config.tip
      })
    }
  })
}
