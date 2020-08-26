/* eslint-disable require-jsdoc, max-lines, no-return-assign, func-style, id-length, no-plusplus, no-use-before-define, no-negated-condition, init-declarations, no-invalid-this, no-param-reassign, no-ternary, multiline-ternary, no-nested-ternary, no-eval, no-extend-native, prefer-reflect */
/* eslint dot-location: ["error", "property"], no-negated-condition: "error" */
/* eslint no-unused-expressions: ["error", { "allowTernary": true }] */
/* eslint no-unused-vars: ["error", { "args": "none" }] */
/* global d3 */

// = require_self
// = require d3
((exports) => {
  const { Decidim: { Visualizations: render } } = exports;

  // lib
  const renderOrgCharts = () => {
    const $orgChartContainer = $(".js-orgchart")
    const $btnReset = $(".js-reset-orgchart")

    let dataDepicted = null
    let fake = false
    let orgchart = {}

    // lib - https://bl.ocks.org/bumbeishvili/b96ba47ea21d14dfce6ebb859b002d3a
    const renderChartCollapsibleNetwork = (params) => {

      // exposed variables
      let attrs = {
        id: `id${Math.floor(Math.random() * 1000000)}`,
        svgWidth: 960,
        svgHeight: 600,
        marginTop: 0,
        marginBottom: 5,
        marginRight: 0,
        marginLeft: 30,
        container: "body",
        distance: 150,
        hiddenChildLevel: 1,
        hoverOpacity: 0.2,
        maxTextDisplayZoomLevel: 1,
        lineStrokeWidth: 1.5,
        fakeRoot: false,
        nodeGutter: { x: 16, y: 8 },
        childrenIndicatorRadius: 15,
        fakeBorderWidth: 32,
        data: null
      }

      /* ############### IF EXISTS OVERWRITE ATTRIBUTES FROM PASSED PARAM  #######  */

      let attrKeys = Object.keys(attrs)
      attrKeys.forEach(function (key) {
        if (params && params[key]) {
          attrs[key] = params[key]
        }
      })

      // innerFunctions which will update visuals
      let updateData
      let collapse, expand
      let filter
      let hierarchy = {}

      // main chart object
      let main = function (selection) {
        selection.each(function scope() {

          // calculated properties
          let calc = {}
          calc.chartLeftMargin = attrs.marginLeft
          calc.chartTopMargin = attrs.marginTop
          calc.chartWidth = attrs.svgWidth - attrs.marginRight - calc.chartLeftMargin
          calc.chartHeight = attrs.svgHeight - attrs.marginBottom - calc.chartTopMargin

          // ########################## HIERARCHY STUFF  #########################
          hierarchy.root = d3.hierarchy(attrs.data.root)

          // ###########################   BEHAVIORS #########################
          let behaviors = {}
          // behaviors.zoom = d3.zoom().scaleExtent([0.75, 100, 8]).on("zoom", zoomed)
          behaviors.drag = d3.drag().on("start", dragstarted).on("drag", dragged).on("end", dragended)

          // ###########################   LAYOUTS #########################
          let layouts = {}

          // custom radial layout
          layouts.radial = d3.radial()

          // ###########################   FORCE STUFF #########################
          let force = {}
          force.link = d3.forceLink().id((d) => d.id)
          force.charge = d3.forceManyBody().strength(-240)
          force.center = d3.forceCenter(calc.chartWidth / 2, calc.chartHeight / 2)

          // prevent collide
          force.collide = d3.forceCollide().radius((d) => {
            // Creates an invented radius based on element measures: diagonal = 2 * radius = sqrt(width^2, height^2)
            let base = (d.bbox || {}).width + (attrs.nodeGutter.x * 2)
            let height = (d.bbox || {}).height + (attrs.nodeGutter.y * 2)
            let diagonal = Math.sqrt(Math.pow(base, 2) + Math.pow(height, 2))
            let fakeRadius = (diagonal / 2)

            // return d3.max([attrs.nodeDistance * 3, fakeRadius])
            return fakeRadius * 1.5
          })

          // manually set x positions (which is calculated using custom radial layout)
          force.x = d3.forceX()
            .strength(0.5)
            .x(function (d) {

              // if node does not have children and is channel (depth=2) , then position it on parent's coordinate
              if (!d.children && d.depth > 2) {
                if (d.parent) {
                  d = d.parent
                }
              }

              // custom circle projection -  radius will be -  (d.depth - 1) * 150
              return projectCircle(d.proportion, (d.depth - 1) * attrs.distance)[0]
            })

          // manually set y positions (which is calculated using d3.cluster)
          force.y = d3.forceY()
            .strength(0.5)
            .y(function (d) {

              // if node does not have children and is channel (depth=2) , then position it on parent's coordinate
              if (!d.children && d.depth > 2) {
                if (d.parent) {
                  d = d.parent
                }
              }

              // custom circle projection -  radius will be -  (d.depth - 1) * 150
              return projectCircle(d.proportion, (d.depth - 1) * attrs.distance)[1]
            })

          // ---------------------------------  INITIALISE FORCE SIMULATION ----------------------------

          // get based on top parameter simulation
          force.simulation = d3.forceSimulation()
            .force("link", force.link)
            .force("charge", force.charge)
            .force("center", force.center)
            .force("collide", force.collide)
            .force("x", force.x)
            .force("y", force.y)

          // ###########################   HIERARCHY STUFF #########################

          // flatten root
          let arr = flatten(hierarchy.root)

          // hide members based on their depth
          arr.forEach((d) => {
            // Hide fake root node
            if ((attrs.fakeRoot) && (d.depth === 1)) {
              d.hidden = true
            }

            if (d.depth > attrs.hiddenChildLevel) {
              d._children = d.children
              d.children = null
            }
          })

          // ####################################  DRAWINGS #######################

          // drawing containers
          let container = d3.select(this)

          // add svg
          let svg = container.patternify({ tag: "svg", selector: "svg-chart-container" })
            .attr("width", attrs.svgWidth)
            .attr("height", attrs.svgHeight)
            // .call(behaviors.zoom)

          // add container g element
          let chart = svg.patternify({ tag: "g", selector: "chart" })
            .attr("transform", `translate(${calc.chartLeftMargin},${calc.chartTopMargin})`)

          // ################################   Chart Content Drawing ##################################

          // link wrapper
          let linksWrapper = chart.patternify({ tag: "g", selector: "links-wrapper" })

          // node wrapper
          let nodesWrapper = chart.patternify({ tag: "g", selector: "nodes-wrapper" })
          let links, nodes

          // reusable function which updates visual based on data change
          update()

          // update visual based on data change
          function update(clickedNode) {

            // Show/hide reset button
            (clickedNode) ? $btnReset.removeClass("invisible") : $btnReset.addClass("invisible")

            // set xy and proportion properties with custom radial layout
            layouts.radial(hierarchy.root)

            // nodes and links array
            let nodesArr = flatten(hierarchy.root, true)
              .orderBy((d) => d.depth)
              .filter((d) => !d.hidden)

            let linksArr = hierarchy.root.links()
              .filter((d) => !d.source.hidden)
              .filter((d) => !d.target.hidden)

            // make new nodes to appear near the parents
            nodesArr.forEach(function (d) {
              if (clickedNode && clickedNode.id === (d.parent && d.parent.id)) {
                d.x = d.parent.x
                d.y = d.parent.y
              }
            })

            // links
            links = linksWrapper.selectAll(".link")
              .data(linksArr, (d) => d.target.id)
            links.exit().remove()

            links = links.enter()
              .append("line")
              .attr("class", "link")
              .merge(links)

            // node groups
            nodes = nodesWrapper.selectAll(".node")
              .data(nodesArr, (d) => d.id)
            nodes.exit().remove()

            let enteredNodes = nodes.enter()
              .append("g")
              .attr("class", "node")

            // bind event handlers
            enteredNodes
              .on("click", nodeClick)
              .on("mouseenter", nodeMouseEnter)
              .on("mouseleave", nodeMouseLeave)
              .call(behaviors.drag)

            // channels grandchildren
            enteredNodes.append("rect")
              .attr("class", "as-card")
              .attr("rx", 4)
              .attr("ry", 4)

            enteredNodes.append("text")
              .attr("class", "as-text")
              .text((d) => d.data.name)

            enteredNodes.selectAll("text").each(function(d) {
              d.bbox = this.getBBox()
            })

            enteredNodes.selectAll("rect")
              .attr("x", (d) => d.bbox.x - attrs.nodeGutter.x)
              .attr("y", (d) => d.bbox.y - attrs.nodeGutter.y)
              .attr("width", (d) => d.bbox.width + (2 * attrs.nodeGutter.x))
              .attr("height", (d) => d.bbox.height + (2 * attrs.nodeGutter.y))

            // append circle & text only when there are children
            enteredNodes
              .append("circle")
              .filter((d) => Boolean(d.children) || Boolean(d._children))
              .attr("class", "as-circle")
              .attr("r", attrs.childrenIndicatorRadius)
              .attr("cx", (d) => d.bbox.x + d.bbox.width + attrs.nodeGutter.x)
              .attr("cy", (d) => d.bbox.y + d.bbox.height + attrs.nodeGutter.y)

            enteredNodes
              .append("text")
              .filter((d) => Boolean(d.children) || Boolean(d._children))
              .attr("class", "as-text")
              .attr("dx", (d) => d.bbox.x + d.bbox.width + attrs.nodeGutter.x)
              .attr("dy", attrs.childrenIndicatorRadius + 3)
              .text((d) => d3.max([(d.children || {}).length, (d._children || {}).length]))

            // merge  node groups and style it
            nodes = enteredNodes.merge(nodes)

            // force simulation
            force.simulation.nodes(nodesArr).on("tick", ticked)

            // links simulation
            force.simulation.force("link").links(links).id((d) => d.id).distance(attrs.distance * 2).strength(2)
          }

          // ####################################### EVENT HANDLERS  ########################

          // zoom handler
          // function zoomed() {
          //   // get transform event
          //   let transform = d3.event.transform
          //   attrs.lastTransform = transform
          //
          //   // apply transform event props to the wrapper
          //   chart.attr("transform", transform)
          //
          //   svg.selectAll(".node").attr("transform", (d) => `translate(${d.x},${d.y}) scale(${1 / (attrs.lastTransform ? attrs.lastTransform.k : 1)})`)
          //   svg.selectAll(".link").attr("stroke-width", attrs.lineStrokeWidth / (attrs.lastTransform ? attrs.lastTransform.k : 1))
          // }

          // tick handler
          function ticked() {
            const fakeBorderWidth = attrs.fakeBorderWidth
            const maxXValueAvailable = (value) => Math.max(Math.min(calc.chartWidth - fakeBorderWidth, value), fakeBorderWidth)
            const maxYValueAvailable = (value) => Math.max(Math.min(calc.chartHeight - fakeBorderWidth, value), fakeBorderWidth)
            // set links position
            links
              .attr("x1", (d) => maxXValueAvailable(d.source.x))
              .attr("y1", (d) => maxYValueAvailable(d.source.y))
              .attr("x2", (d) => maxXValueAvailable(d.target.x))
              .attr("y2", (d) => maxYValueAvailable(d.target.y))

            // set nodes position
            svg.selectAll(".node")
              .attr("transform", (d) => `translate(${maxXValueAvailable(d.x)},${maxYValueAvailable(d.y)})`)
          }

          // handler drag start event
          function dragstarted() {
            // disable node fixing
            nodes.each((d) => {
              d.fx = null
              d.fy = null
            })
          }

          // handle dragging event
          function dragged(d) {
            // make dragged node fixed
            d.fx = d3.event.x
            d.fy = d3.event.y
          }

          // -------------------- handle drag end event ---------------
          function dragended() {
            // we are doing nothing, here , aren't we?
          }

          // -------------------------- node mouse hover handler ---------------
          function nodeMouseEnter(d) {
            // get links
            let _links = hierarchy.root.links()

            // get hovered node connected links
            let connectedLinks = _links.filter((l) => l.source.id === d.id || l.target.id === d.id)

            // get hovered node linked nodes
            let linkedNodes = connectedLinks.map((s) => s.source.id).concat(connectedLinks.map((c) => c.target.id))

            // reduce all other nodes opacity
            nodesWrapper.selectAll(".node")
              .filter((n) => linkedNodes.indexOf(n.id) === -1)
              .attr("opacity", attrs.hoverOpacity)

            // reduce all other links opacity
            linksWrapper.selectAll(".link")
              .attr("opacity", attrs.hoverOpacity)

            // highlight hovered nodes connections
            linksWrapper.selectAll(".link")
              .filter((l) => l.source.id === d.id || l.target.id === d.id)
              .attr("opacity", 1)
          }

          // --------------- handle mouseleave event ---------------
          function nodeMouseLeave() {
            // return things back to normal
            nodesWrapper.selectAll(".node")
              .attr("opacity", 1)
            linksWrapper.selectAll(".link")
              .attr("opacity", 1)
          }

          // --------------- handle node click event ---------------
          function nodeClick(d) {
            // free fixed nodes
            nodes.each((di) => {
              di.fx = null
              di.fy = null
            })

            // collapse or expand node
            if (d.children) {
              collapse(d)
            } else if (d._children) {
              expand(d)
            } else {
            // nothing is to collapse or expand
            }

            freeNodes()
          }

          // #########################################  UTIL FUNCS ##################################
          updateData = function () {
            main.run()
          }

          collapse = function (d, deep = false) {
            if (d.children) {
              if (deep) {
                d.children.forEach((e) => collapse(e, true))
              }

              d._children = d.children
              d.children = null
            }

            update(d)
            force.simulation.restart()
            force.simulation.alphaTarget(0.15)
          }

          expand = function (d, deep = false) {
            if (d._children) {
              if (deep) {
                d._children.forEach((e) => expand(e, true))
              }

              d.children = d._children
              d._children = null
            }

            update(d)
            force.simulation.restart()
            force.simulation.alphaTarget(0.15)
          }

          // function slowDownNodes() {
          //   force.simulation.alphaTarget(0.05)
          // }

          // function speedUpNodes() {
          //   force.simulation.alphaTarget(0.45)
          // }

          function freeNodes() {
            d3.selectAll(".node").each((n) => {
              n.fx = null
              n.fy = null
            })
          }

          function projectCircle(value, radius) {
            let r = radius || 0
            let corner = value * 2 * Math.PI
            return [Math.sin(corner) * r, -Math.cos(corner) * r]
          }

          // recursively loop on children and extract nodes as an array
          function flatten(root, clustered) {
            let nodesArray = []
            let i = 0
            function recurse(node, depth) {
              if (node.children) {
                node.children.forEach(function (child) {
                  recurse(child, depth + 1)
                })
              }

              if (!node.id) {
                node.id = ++i
              } else {
                ++i
              }

              node.depth = depth
              if (clustered) {
                if (!node.cluster) {
                // if cluster coordinates are not set, set it
                  node.cluster = { x: node.x, y: node.y }
                }
              }
              nodesArray.push(node)
            }
            recurse(root, 1)
            return nodesArray
          }

          function debug() {
            if (attrs.isDebug) {
            // stringify func
              let stringified = String(scope)

              // parse variable names
              let groupVariables = stringified
                // match var x-xx= {}
                .match(/var\s+([\w])+\s*=\s*{\s*}/gi)
                // match xxx
                .map((d) => d.match(/\s+\w*/gi).filter((s) => s.trim()))
                // get xxx
                .map((v) => v[0].trim())

              // assign local variables to the scope
              groupVariables.forEach((v) => {
                main[`P_${v}`] = eval(v)
              })
            }
          }

          debug()

        })
      }

      // ----------- PROTOTYEPE FUNCTIONS  ----------------------
      d3.selection.prototype.patternify = function (_params) {
        let selector = _params.selector
        let elementTag = _params.tag
        let _data = _params.data || [selector]

        // pattern in action
        let selection = this.selectAll(`.${selector}`).data(_data)
        selection.exit().remove()
        selection = selection.enter().append(elementTag).merge(selection)
        selection.attr("class", selector)

        return selection
      }

      // custom radial layout
      d3.radial = function () {
        return function (root) {

          recurse(root, 0, 1)

          function recurse(node, min, max) {
            node.proportion = (max + min) / 2
            if (!node.x) {

              // if node has parent, match entered node positions to it's parent
              if (node.parent) {
                node.x = node.parent.x
              } else {
                node.x = 0
              }
            }

            // if node had parent, match entered node positions to it's parent
            if (!node.y) {
              if (node.parent) {
                node.y = node.parent.y
              } else {
                node.y = 0
              }
            }

            // recursively do the same for children
            if (node.children) {
              let offset = (max - min) / node.children.length
              node.children.forEach(function (child, i) {
                let newMin = min + (offset * i)
                let newMax = newMin + offset

                recurse(child, newMin, newMax)
              })
            }
          }
        }
      }

      // https://github.com/bumbeishvili/d3js-boilerplates#orderby
      Array.prototype.orderBy = function (func) {
        this.sort((_a, _b) => {
          let a = func(_a)
          let b = func(_b)
          if (typeof a === "string" || a instanceof String) {
            return a.localeCompare(b)
          }
          return a - b
        })

        return this
      }

      // ##########################  BOILEPLATE STUFF ################

      // dinamic keys functions
      Object.keys(attrs).forEach((key) => {
        // Attach variables to main function
        return main[key] = function (_) {
          let string = `attrs['${key}'] = _`

          if (!arguments.length) {
            return eval(` attrs['${key}'];`)
          }

          eval(string)

          return main
        }
      })

      // set attrs as property
      main.attrs = attrs

      // debugging visuals
      main.debug = function (isDebug) {
        attrs.isDebug = isDebug
        if (isDebug) {
          if (!window.charts) {
            window.charts = []
          }
          window.charts.push(main)
        }
        return main
      }

      // exposed update functions
      main.data = function (value) {
        if (!arguments.length) {
          return attrs.data
        }

        attrs.data = value
        if (typeof updateData === "function") {
          updateData()
        }
        return main
      }

      // run  visual
      main.run = function () {
        d3.selectAll(attrs.container)
          .call(main)
        return main
      }

      main.filter = function (filterParams) {
        if (!arguments.length) {
          return attrs.filterParams
        }

        attrs.filterParams = filterParams
        if (typeof filter === "function") {
          filter()
        }
        return main
      }

      main.reset = function () {

        hierarchy.root.children.forEach((e) => collapse(e, true))
        main.run()

        return main
      }

      return main
    }

    // initialization
    $orgChartContainer.each((i, container) => {

      let $container = $(container)
      let width = $container.width()
      let height = width / (16 / 9)

      d3.json($container.data("url")).then((data) => {
        // Make a fake previous node if the data entry is not hierarchical
        if (data instanceof Array) {
          fake = true
          dataDepicted = {
            name: null,
            children: data
          }
        } else {
          dataDepicted = data
        }

        orgchart = renderChartCollapsibleNetwork()
          .svgHeight(height)
          .svgWidth(width)
          .fakeRoot(fake)
          .container(`#${container.id}`)
          .data({
            root: dataDepicted
          })
          .debug(true)
          .run()
      })
    })

    // reset
    $btnReset.click(function() {
      orgchart.reset()
    })
  }

  $(() => {
    render(renderOrgCharts);
  })
})(window);
