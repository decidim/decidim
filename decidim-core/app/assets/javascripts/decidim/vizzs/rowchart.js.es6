/* global d3, DATACHARTS, fetchDatacharts */
/* eslint-disable id-length, no-unused-vars, multiline-ternary, no-ternary, no-nested-ternary, no-invalid-this */
/* eslint prefer-reflect: ["error", { "exceptions": ["call"] }] */
/* eslint dot-location: ["error", "property"] */

// = require d3

const renderRowCharts = () => {
  // lib
  const rowchart = (opts = {}) => {
    // parse opts
    let data = opts.data
    let title = opts.title
    let container = d3.select(opts.container)
    let ratio = opts.ratio
    let showTooltip = opts.tip !== "false"

    // set the dimensions and margins of the graph
    let margin = {
      top: 10,
      right: 10,
      bottom: 20,
      left: 150
    }

    let width = Number(container.node().getBoundingClientRect().width) - margin.left - margin.right
    let height = (width / ratio) - margin.top - margin.bottom

    // set the ranges
    const x = d3.scaleLinear().rangeRound([0, width])
    const y0 = d3.scaleBand().rangeRound([height, 0]).paddingInner(0.1)
    const y1 = d3.scaleBand().padding(0.05)
    // const z = d3.scaleOrdinal()

    // set the scales
    // Explanation: get the inner values foreach object outer values, flat the array, remove duplicates
    let values = d3.extent([...new Set([].concat(...data.map((f) => f.value.map((d) => d.value))))])
    x.domain(values)
    // group names
    y0.domain(data.map((d) => d.key))
    // Explanation: get the inner keys foreach object outer values, flat the array, remove duplicates
    let keys = [...new Set([].concat(...data.map((f) => f.value.map((d) => d.key))))]
    // individual values for each group
    y1.domain(keys).rangeRound([0, y0.bandwidth()])

    let svg = container.append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`)

    let barGroup = svg.selectAll("g")
      .data(data)
      .enter().append("g")
      .attr("transform", (d) => `translate(0,${y0(d.key)})`)

    let bar = barGroup.selectAll("rect")
      .data((d) => d.value)
      .enter().append("rect")
      .attr("y", (d) => y1(d.key))
      .attr("width", (d) => x(d.value))
      .attr("height", y1.bandwidth())

    // axis
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", `translate(0,${height})`)
      .call(d3.axisBottom(x))

    svg.append("g")
      .attr("class", "y axis")
      .call(d3.axisLeft(y0))

  }

  return $(".rowchart:visible").each((i, container) => {

    // Initialize dataset values
    const init = (dataset) => {
      const datasetDefault = {
        metric: "",
        title: "",
        ratio: "",
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

      rowchart({
        container: `#${container.id}`,
        title: config.title,
        data: data,
        // data: dataModified,
        ratio: config.ratio.split(":").reduce((a, b) => a / b) || (4 / 3),
        tip: config.tip
      })
    }
  })
}
