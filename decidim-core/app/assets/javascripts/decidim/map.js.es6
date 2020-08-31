// = require leaflet
// = require leaflet-tilelayer-here
// = require leaflet-svg-icon
// = require leaflet.markercluster
// = require jquery-tmpl
// = require_self

L.DivIcon.SVGIcon.DecidimIcon = L.DivIcon.SVGIcon.extend({
  options: {
    fillColor: "#ef604d",
    opacity: 0
  },
  _createPathDescription: function() {
    return "M14 1.17a11.685 11.685 0 0 0-11.685 11.685c0 11.25 10.23 20.61 10.665 21a1.5 1.5 0 0 0 2.025 0c0.435-.435 10.665-9.81 10.665-21A11.685 11.685 0 0 0 14 1.17Zm0 17.415A5.085 5.085 0 1 1 19.085 13.5 5.085 5.085 0 0 1 14 18.585Z";
  },
  _createCircle: function() {
    return ""
  },
  // Improved version of the _createSVG, essentially the same as in later
  // versions of Leaflet. It adds the `px` values after the width and height
  // CSS making the focus borders work correctly across all browsers.
  _createSVG: function() {
    const path = this._createPath();
    const circle = this._createCircle();
    const text = this._createText();
    const className = `${this.options.className}-svg`;

    const style = `width:${this.options.iconSize.x}px; height:${this.options.iconSize.y}px;`;

    const svg = `<svg xmlns="http://www.w3.org/2000/svg" version="1.1" class="${className}" style="${style}">${path}${circle}${text}</svg>`;

    return svg;
  }
});

const popupTemplateId = "marker-popup";
$.template(popupTemplateId, $(`#${popupTemplateId}`).html());

const addMarkers = (markersData, markerClusters, map) => {
  const bounds = new L.LatLngBounds(markersData.map((markerData) => [markerData.latitude, markerData.longitude]));

  markersData.forEach((markerData) => {
    let marker = L.marker([markerData.latitude, markerData.longitude], {
      icon: new L.DivIcon.SVGIcon.DecidimIcon({
        fillColor: window.Decidim.mapConfiguration.markerColor
      }),
      keyboard: true,
      title: markerData.title
    });
    let node = document.createElement("div");

    $.tmpl(popupTemplateId, markerData).appendTo(node);

    marker.bindPopup(node, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }).openPopup();

    markerClusters.addLayer(marker);
  });

  map.addLayer(markerClusters);
  map.fitBounds(bounds, { padding: [100, 100] });
};

const loadMap = (mapId, markersData) => {
  let markerClusters = L.markerClusterGroup();

  if (window.Decidim.currentMap) {
    window.Decidim.currentMap.remove();
    window.Decidim.currentMap = null;
  }

  const map = L.map(mapId);

  L.tileLayer.here(window.Decidim.mapConfiguration).addTo(map);

  if (markersData.length > 0) {
    addMarkers(markersData, markerClusters, map);
  } else {
    map.fitWorld();
  }

  map.scrollWheelZoom.disable();

  // Fix the keyboard navigation on the map
  map.on("popupopen", (ev) => {
    const $popup = $(ev.popup.getElement());
    $popup.attr("tabindex", 0).focus();
  });
  map.on("popupclose", (ev) => {
    $(ev.popup._source._icon).focus();
  });

  return map;
};

window.Decidim = window.Decidim || {};

window.Decidim.loadMap = loadMap;
window.Decidim.currentMap =  null;
window.Decidim.mapConfiguration = {};

$(() => {
  const mapId = "map";
  const $map = $(`#${mapId}`);

  const markersData = $map.data("markers-data");
  const hereAppId = $map.data("here-app-id");
  const hereAppCode = $map.data("here-app-code");
  const hereApiKey = $map.data("here-api-key");

  let markerColor = getComputedStyle(document.documentElement).getPropertyValue("--primary");
  if (!markerColor || markerColor.length < 1) {
    markerColor = "#ef604d";
  }

  let mapApiConfig = null;
  if (hereApiKey) {
    mapApiConfig = { apiKey: hereApiKey };
  } else {
    mapApiConfig = {
      appId: hereAppId,
      appCode: hereAppCode
    };
  }
  window.Decidim.mapConfiguration = $.extend({
    markerColor: markerColor
  }, mapApiConfig);

  if ($map.length > 0) {
    window.Decidim.currentMap = loadMap(mapId, markersData);
  }
});
