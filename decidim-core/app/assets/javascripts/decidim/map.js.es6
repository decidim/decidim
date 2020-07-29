// = require decidim/map/controller
// = require_self

((exports) => {
  const $ = exports.$; // eslint-disable-line

  exports.Decidim = exports.Decidim || {};
  const MapController = exports.Decidim.MapController;

  $(() => {
    let $mapElements = $("[data-decidim-map]");
    if ($mapElements.length < 1 && $("#map").length > 0) {
      throw new Error(
        "DEPRECATION: Please update your maps customizations or include 'decidim/map/legacy.js' for legacy support!"
      );
    }

    $mapElements.each((_i, el) => {
      const $map = $(el);
      const mapId = $map.attr("id");

      const mapConfig = $map.data("decidim-map");
      const ctrl = new MapController(mapId, mapConfig);
      const map = ctrl.load();

      $map.data("map", map);
      $map.data("map-controller", ctrl);

      $map.trigger("configure.decidim", [map, mapConfig]);

      if (mapConfig.markers.length > 0) {
        ctrl.addMarkers(mapConfig.markers);
      } else {
        ctrl.getMap().fitWorld();
      }

      // Indicates the map is loaded with the map objects initialized and ready
      // to be used.
      $map.trigger("ready.decidim", [map, mapConfig]);
    });
  });
})(window);
