/**
 * @deprecated
 *
 * This adds back the old map methods for backwards compatibility. This is not
 * really needed unless someone is still relying on these methods.
 */
((exports) => {
  exports.Decidim = exports.Decidim || {};

  const MapController = exports.Decidim.MapController;

  const legacyMapSupport = ($map) => {
    const hereAppId = $map.data("here-app-id");
    const hereAppCode = $map.data("here-app-code");
    const hereApiKey = $map.data("here-api-key");

    let mapApiConfig = null;
    if (hereApiKey) {
      mapApiConfig = { apiKey: hereApiKey };
    } else {
      mapApiConfig = {
        appId: hereAppId,
        appCode: hereAppCode
      };
    }

    const markersData = $map.data("markers-data");

    let markerColor = getComputedStyle(document.documentElement).getPropertyValue("--primary");
    if (!markerColor || markerColor.length < 1) {
      markerColor = "#ef604d";
    }

    // Configure the map element with the new style
    const mapConfig = {
      settings: {
        markerColor,
        popupTemplateId: "marker-popup"
      },
      markers: markersData,
      tileLayer: mapApiConfig
    }

    $map.data("decidim-map", mapConfig);
    $map.on("configure.decidim", (mapObj, mapDetails) => {
      L.tileLayer.here(mapDetails.tileLayer).addTo(mapObj);
    });

    window.Decidim.mapConfiguration = mapConfig;
  };

  const loadMap = (mapId, markersData) => {
    if (window.Decidim.currentMap) {
      window.Decidim.currentMap.remove();
      window.Decidim.currentMap = null;
    }

    const ctrl = new MapController(mapId, { markers: markersData });
    const map = ctrl.load();

    // Allow the configured map service to configure the map, e.g. attaching the
    // tile layer to the map.
    const $map = $(`#${mapId}`);
    legacyMapSupport($map);

    if (markersData.length > 0) {
      ctrl.addMarkers(markersData);
    } else {
      ctrl.getMap().fitWorld();
    }

    exports.Decidim.currentMap = map;

    return map;
  };

  exports.Decidim.legacyMapSupport = legacyMapSupport;
  exports.Decidim.loadMap = loadMap;
  exports.Decidim.currentMap =  null;
  exports.Decidim.mapConfiguration = {};
})(window);
