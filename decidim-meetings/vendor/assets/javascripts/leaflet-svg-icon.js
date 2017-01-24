//Leaflet-SVGIcon
//SVG icon for any marker class
//Ilya Atkin
//ilya.atkin@unh.edu

L.DivIcon.SVGIcon = L.DivIcon.extend({
    options: {
        "circleText": "",
        "className": "svg-icon",
        "circleAnchor": null, //defaults to [iconSize.x/2, iconSize.x/2]
        "circleColor": null, //defaults to color
        "circleOpacity": null, // defaults to opacity
        "circleFillColor": "rgb(255,255,255)",
        "circleFillOpacity": null, //default to opacity 
        "circleRatio": 0.5,
        "circleWeight": null, //defaults to weight
        "color": "rgb(0,102,255)",
        "fillColor": null, // defaults to color
        "fillOpacity": 0.4,
        "fontColor": "rgb(0, 0, 0)",
        "fontOpacity": "1",
        "fontSize": null, // defaults to iconSize.x/4
        "iconAnchor": null, //defaults to [iconSize.x/2, iconSize.y] (point tip)
        "iconSize": L.point(32,48),
        "opacity": 1,
        "popupAnchor": null,
        "weight": 2
    },
    initialize: function(options) {
        options = L.Util.setOptions(this, options)

        if (!options.circleAnchor) {
            options.circleAnchor = L.point(Number(options.iconSize.x)/2, Number(options.iconSize.x)/2)
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
            options.fontSize = Number(options.iconSize.x/4) 
        }
        if (!options.iconAnchor) {
            options.iconAnchor = L.point(Number(options.iconSize.x)/2, Number(options.iconSize.y))
        }
        if (!options.popupAnchor) {
            options.popupAnchor = L.point(0, (-0.75)*(options.iconSize.y))
        }

        var path = this._createPath()
        var circle = this._createCircle()

        options.html = this._createSVG()
    },
    _createCircle: function() {
        var cx = Number(this.options.circleAnchor.x) 
        var cy = Number(this.options.circleAnchor.y)
        var radius = this.options.iconSize.x/2 * Number(this.options.circleRatio)
        var fill = this.options.circleFillColor.replace("rgb(", "rgba(").replace(")", "," + this.options.circleFillOpacity + ")")
        var stroke = this.options.circleColor.replace("rgb(", "rgba(").replace(")", "," + this.options.circleOpacity + ")")
        var strokeWidth = this.options.circleWeight
        var className = this.options.className + "-circle"

        var circle = '<circle class="' + className + '" cx="' + cx + '" cy="' + cy + '" r="' + radius + '" fill="' + fill + '" stroke="' + stroke + '" stroke-width="' + strokeWidth + '"/>'

        return circle
    },
    _createPathDescription: function() {
        var height = Number(this.options.iconSize.y)
        var width = Number(this.options.iconSize.x)
        var weight = Number(this.options.weight)
        var margin = weight / 2

        var startPoint = "M " + margin + " " + (width/2) + " "
        var leftLine = "L " + (width/2) + " " + (height - weight) + " "
        var rightLine = "L " + (width - margin) + " " + (width/2) + " "
        var arc = "A " + (width/4) + " " + (width/4) + " 0 0 0 " + margin + " " + (width/2) + " Z"

        var d = startPoint + leftLine + rightLine + arc

        return d
    },
    _createPath: function() {
        var pathDescription = this._createPathDescription()
        var strokeWidth = this.options.weight
        var stroke = this.options.color.replace("rgb(", "rgba(").replace(")", "," + this.options.opacity + ")")
        var fill = this.options.fillColor.replace("rgb(", "rgba(").replace(")", "," + this.options.fillOpacity + ")")
        var className = this.options.className + "-path"

        var path = '<path class="' + className + '" d="' + pathDescription + '" stroke-width="' + strokeWidth + '" stroke="' + stroke + '" fill="' + fill + '"/>'

        return path
    },
    _createSVG: function() {
        var path = this._createPath()
        var circle = this._createCircle()
        var text = this._createText()
        var className = this.options.className + "-svg"

        var style = "width:" + this.options.iconSize.x + "; height:" + this.options.iconSize.y + ";"

        var svg = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" class="' + className + '" style="' + style + '">' + path + circle + text + '</svg>'

        return svg
    },
    _createText: function() {
        var fontSize = this.options.fontSize + "px"
        var lineHeight = Number(this.options.fontSize)

        var x = Number(this.options.iconSize.x) / 2
        var y = x + (lineHeight * 0.35) //35% was found experimentally 
        var circleText = this.options.circleText
        var textColor = this.options.fontColor.replace("rgb(", "rgba(").replace(")", "," + this.options.fontOpacity + ")")

        var text = '<text text-anchor="middle" x="' + x + '" y="' + y + '" style="font-size: ' + fontSize + '" fill="' + textColor + '">' + circleText + '</text>'

        return text
    }
})

L.divIcon.svgIcon = function(options) {
    return new L.DivIcon.SVGIcon(options)
}

L.Marker.SVGMarker = L.Marker.extend({
    options: {
        "iconFactory": L.divIcon.svgIcon,
        "iconOptions": {}
    },
    initialize: function(latlng, options) {
        options = L.Util.setOptions(this, options)
        options.icon = options.iconFactory(options.iconOptions)
        this._latlng = latlng
    },
    onAdd: function(map) {
        L.Marker.prototype.onAdd.call(this, map)
    },
    setStyle: function(style) {
        if (this._icon) {
            var svg = this._icon.children[0]
            var iconBody = this._icon.children[0].children[0]
            var iconCircle = this._icon.children[0].children[1]

            if (style.color && !style.iconOptions) {
                var stroke = style.color.replace("rgb","rgba").replace(")", ","+this.options.icon.options.opacity+")")
                var fill = style.color.replace("rgb","rgba").replace(")", ","+this.options.icon.options.fillOpacity+")")
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
                if (style.color) { style.iconOptions.color = style.color }
                iconOptions = L.Util.setOptions(this.options.icon, style.iconOptions)
                this.setIcon(L.divIcon.svgIcon(iconOptions))
            }
        }
    }
})

L.marker.svgMarker = function(latlng, options) {
    return new L.Marker.SVGMarker(latlng, options)
}
