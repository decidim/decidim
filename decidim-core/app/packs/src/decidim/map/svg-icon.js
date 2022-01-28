/* eslint prefer-reflect: 0 */

// Leaflet-SVGIcon
// SVG icon for any marker class
//
// Copyright (c) 2016 University of New Hampshire - The MIT License
// Author: Ilya Atkin <ilya.atkin@unh.edu>
// Originally copied from https://github.com/iatkin/leaflet-svgicon
//

let SVGIcon = L.DivIcon.extend({
  options: {
    "circleText": "",
    "className": "svg-icon",
    // defaults to [iconSize.x/2, iconSize.x/2]
    "circleAnchor": null,
    // defaults to color
    "circleColor": null,
    // defaults to opacity
    "circleOpacity": null,
    "circleFillColor": "rgb(255,255,255)",
    // default to opacity
    "circleFillOpacity": null,
    "circleRatio": 0.5,
    // defaults to weight
    "circleWeight": null,
    "color": "rgb(0,102,255)",
    // defaults to color
    "fillColor": null,
    "fillOpacity": 0.4,
    "fontColor": "rgb(0, 0, 0)",
    "fontOpacity": "1",
    // defaults to iconSize.x/4
    "fontSize": null,
    "fontWeight": "normal",
    // defaults to [iconSize.x/2, iconSize.y] (point tip)
    "iconAnchor": null,
    "iconSize": L.point(32, 48),
    "opacity": 1,
    "popupAnchor": null,
    "shadowAngle": 45,
    "shadowBlur": 1,
    "shadowColor": "rgb(0,0,10)",
    "shadowEnable": false,
    "shadowLength": 0.75,
    "shadowOpacity": 0.5,
    "shadowTranslate": L.point(0, 0),
    "weight": 2
  },
  initialize: function(_options) {
    let options = L.Util.setOptions(this, _options)

    // iconSize needs to be converted to a Point object if it is not passed as one
    options.iconSize = L.point(options.iconSize)

    // in addition to setting option dependant defaults, Point-based options are converted to Point objects
    if (options.circleAnchor) {
      options.circleAnchor = L.point(options.circleAnchor)
    } else {
      options.circleAnchor = L.point(Number(options.iconSize.x) / 2, Number(options.iconSize.x) / 2)
    }
    if (!options.circleColor) {
      options.circleColor = options.color
    }
    if (!options.circleFillOpacity) {
      options.circleFillOpacity = options.opacity
    }
    if (!options.circleOpacity) {
      options.circleOpacity = options.opacity
    }
    if (!options.circleWeight) {
      options.circleWeight = options.weight
    }
    if (!options.fillColor) {
      options.fillColor = options.color
    }
    if (!options.fontSize) {
      options.fontSize = Number(options.iconSize.x / 4)
    }
    if (options.iconAnchor) {
      options.iconAnchor = L.point(options.iconAnchor)
    }
    else {
      options.iconAnchor = L.point(Number(options.iconSize.x) / 2, Number(options.iconSize.y))
    }
    if (options.popupAnchor) {
      options.popupAnchor = L.point(options.popupAnchor)
    }
    else {
      options.popupAnchor = L.point(0, (-0.75) * (options.iconSize.y))
    }

    options.html = this._createSVG()
  },
  _createCircle: function() {
    let cx = Number(this.options.circleAnchor.x)
    let cy = Number(this.options.circleAnchor.y)
    let radius = this.options.iconSize.x / 2 * Number(this.options.circleRatio)
    let fill = this.options.circleFillColor
    let fillOpacity = this.options.circleFillOpacity
    let stroke = this.options.circleColor
    let strokeOpacity = this.options.circleOpacity
    let strokeWidth = this.options.circleWeight
    let className = `${this.options.className}-circle`

    let circle = `<circle class="${className}" cx="${cx}" cy="${cy}" r="${radius
    }" fill="${fill}" fill-opacity="${fillOpacity
    }" stroke="${stroke}" stroke-opacity=${strokeOpacity}" stroke-width="${strokeWidth}"/>`

    return circle
  },
  _createPathDescription: function() {
    let height = Number(this.options.iconSize.y)
    let width = Number(this.options.iconSize.x)
    let weight = Number(this.options.weight)
    let margin = weight / 2

    let startPoint = `M ${margin} ${width / 2} `
    let leftLine = `L ${width / 2} ${height - weight} `
    let rightLine = `L ${width - margin} ${width / 2} `
    let arc = `A ${width / 4} ${width / 4} 0 0 0 ${margin} ${width / 2} Z`

    let description = startPoint + leftLine + rightLine + arc

    return description
  },
  _createPath: function() {
    let pathDescription = this._createPathDescription()
    let strokeWidth = this.options.weight
    let stroke = this.options.color
    let strokeOpacity = this.options.opacity
    let fill = this.options.fillColor
    let fillOpacity = this.options.fillOpacity
    let className = `${this.options.className}-path`

    let path = `<path class="${className}" d="${pathDescription
    }" stroke-width="${strokeWidth}" stroke="${stroke}" stroke-opacity="${strokeOpacity
    }" fill="${fill}" fill-opacity="${fillOpacity}"/>`

    return path
  },
  _createShadow: function() {
    let pathDescription = this._createPathDescription()
    let strokeWidth = this.options.weight
    let stroke = this.options.shadowColor
    let fill = this.options.shadowColor
    let className = `${this.options.className}-shadow`

    let origin = `${this.options.iconSize.x / 2}px ${this.options.iconSize.y}px`
    let rotation = this.options.shadowAngle
    let height = this.options.shadowLength
    let opacity = this.options.shadowOpacity
    let blur = this.options.shadowBlur
    let translate = `${this.options.shadowTranslate.x}px, ${this.options.shadowTranslate.y}px`

    let blurFilter = `<filter id='iconShadowBlur'><feGaussianBlur in='SourceGraphic' stdDeviation='${blur}'/></filter>`

    let shadow = `<path filter="url(#iconShadowBlur") class="${className}" d="${pathDescription}" fill="${fill}" stroke-width="${strokeWidth}" stroke="${stroke}" style="opacity: ${opacity}; transform-origin: ${origin}; transform: rotate(${rotation}deg) translate(${translate}) scale(1, ${height})" />`

    return blurFilter + shadow
  },
  _createSVG: function() {
    let path = this._createPath()
    let circle = this._createCircle()
    let text = this._createText()
    let shadow = ""
    if (this.options.shadowEnable) {
      shadow = this._createShadow()
    }

    let className = `${this.options.className}-svg`
    let width = this.options.iconSize.x
    let height = this.options.iconSize.y

    if (this.options.shadowEnable) {
      width += this.options.iconSize.y * this.options.shadowLength - (this.options.iconSize.x / 2)
      width = Math.max(width, 32)
      height += this.options.iconSize.y * this.options.shadowLength
    }

    let style = `width:${width}px; height:${height}`
    let svg = `<svg xmlns="http://www.w3.org/2000/svg" version="1.1" class="${className}" style="${style}">${shadow}${path}${circle}${text}</svg>`

    return svg
  },
  _createText: function() {
    let fontSize = `${this.options.fontSize}px`
    let fontWeight = this.options.fontWeight
    let lineHeight = Number(this.options.fontSize)

    let coordX = this.options.circleAnchor.x
    // 35% was found experimentally
    let coordY = this.options.circleAnchor.y + (lineHeight * 0.35)
    let circleText = this.options.circleText
    let textColor = this.options.fontColor.replace("rgb(", "rgba(").replace(")", `,${this.options.fontOpacity})`)

    let text = `<text text-anchor="middle" x="${coordX}" y="${coordY}" style="font-size: ${fontSize}; font-weight: ${fontWeight}" fill="${textColor}">${circleText}</text>`

    return text
  }
})

let SVGMarker = L.Marker.extend({
  options: {
    "iconFactory": L.divIcon.svgIcon,
    "iconOptions": {}
  },
  initialize: function(latlng, _options) {
    let options = L.Util.setOptions(this, _options)
    options.icon = options.iconFactory(options.iconOptions)
    this._latlng = latlng
  },
  onAdd: function(map) {
    L.Marker.prototype.onAdd.call(this, map)
  },
  setStyle: function(style) {
    if (this._icon) {
      //      let svg = this._icon.children[0]
      let iconBody = this._icon.children[0].children[0]
      let iconCircle = this._icon.children[0].children[1]

      if (style.color && !style.iconOptions) {
        let stroke = style.color.replace("rgb", "rgba").replace(")", `,${this.options.icon.options.opacity})`)
        let fill = style.color.replace("rgb", "rgba").replace(")", `,${this.options.icon.options.fillOpacity})`)
        iconBody.setAttribute("stroke", stroke)
        iconBody.setAttribute("fill", fill)
        iconCircle.setAttribute("stroke", stroke)

        this.options.icon.fillColor = fill
        this.options.icon.color = stroke
        this.options.icon.circleColor = stroke
      }
      if (style.opacity) {
        this.setOpacity(style.opacity)
      }
      if (style.iconOptions) {
        if (style.color) {
          style.iconOptions.color = style.color
        }
        let iconOptions = L.Util.setOptions(this.options.icon, style.iconOptions)
        this.setIcon(L.divIcon.svgIcon(iconOptions))
      }
    }
  }
});

export { SVGMarker, SVGIcon }

