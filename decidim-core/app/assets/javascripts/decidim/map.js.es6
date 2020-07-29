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

      const mapData = $map.data("decidim-map");
      const ctrl = new MapController(mapId, mapData.settings);
      const map = ctrl.load();

      $map.data("map", map);
      $map.data("map-controller", ctrl);

      $map.trigger("configure.decidim", [map, mapData]);

      if (mapData.markers.length > 0) {
        ctrl.addMarkers(mapData.markers);
      } else {
        ctrl.getMap().fitWorld();
      }
    });
  });
})(window);
