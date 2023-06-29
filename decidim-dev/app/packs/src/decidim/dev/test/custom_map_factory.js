import MapMarkersController from "src/decidim/map/controller/markers";

const appendToBody = (content) => {
  const p = document.createElement("p");
  p.innerHTML = content;
  document.body.appendChild(p);
}

class CustomMapController extends MapMarkersController {
  start() {
    this.markerClusters = null;
    this.addMarkers(this.config.markers);

    appendToBody("Custom map started");
  }
}

const origCreateMapController = window.Decidim.createMapController;

const createMapController = (mapId, config) => {
  if (config.type === "custom") {
    return new CustomMapController(mapId, config);
  }

  return origCreateMapController(mapId, config);
}

window.Decidim.createMapController = createMapController;

// Prevent external requests to the Here URLs during tests
if (L.TileLayer.HERE) {
  L.TileLayer.HERE.prototype.onAdd = function(map) {};
}

// Test that the map events are working correctly
$("[data-decidim-map]").on("ready.decidim", (ev, _map, mapConfig) => {
  appendToBody("Custom map ready");
});

appendToBody("LOADED");
