/* eslint-disable require-jsdoc */

import * as L from "leaflet";
import "src/decidim/map/factory"

/**
 * @deprecated
 *
 * This adds support for the legacy style of map configuration and the methods
 * available globally. This is not really needed unless someone is still relying
 * on these methods or the have customizations that are hard to update.
 * @param {Object} $map A selector with the map container
 *
 * @returns {void} Nothing.
 */
const legacyMapSupport = ($map) => {
  const hereAppId = $map.data("here-app-id");
  const hereAppCode = $map.data("here-app-code");
  const hereApiKey = $map.data("here-api-key");

  let mapApiConfig = null;
  if (hereApiKey) {
    mapApiConfig = { apiKey: hereApiKey };
  } else if (hereAppId && hereAppCode) {
    mapApiConfig = {
      appId: hereAppId,
      appCode: hereAppCode
    };
  } else {
    throw new Error("Legacy map support: Please provide the HERE API configuration");
  }

  const markersData = $map.data("markers-data");

  let markerColor = getComputedStyle(document.documentElement).getPropertyValue("--primary");
  if (!markerColor || markerColor.length < 1) {
    markerColor = "#ef604d";
  }

  // Configure the map element with the new style
  const mapConfig = {
    markerColor,
    popupTemplateId: "marker-popup",
    markers: markersData,
    tileLayer: mapApiConfig
  }

  $map.data("decidim-map", mapConfig);

  window.Decidim.mapConfiguration = $.extend({
    markerColor: markerColor
  }, mapApiConfig);
};

const loadMap = (mapId, markersData) => {
  // Allow the configured map service to configure the map, e.g. attaching the
  // tile layer to the map.
  const $map = $(`#${mapId}`);
  $map.data("markers-data", markersData);
  legacyMapSupport($map);

  const mapData = $map.data("decidim-map");
  const ctrl = window.Decidim.createMapController(mapId, mapData);
  const map = ctrl.load();

  L.tileLayer.here(mapData.tileLayer).addTo(map);

  ctrl.start();

  window.Decidim.currentMap = map;

  return map;
};

$(() => {
  const $map = $("#map");
  if ($map.length > 0) {
    loadMap($map.attr("id"), $map.data("markers-data"));
  }
});
