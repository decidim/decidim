// = require decidim/map/controller
// = require decidim/map/legacy
// = require_self

((exports) => {
  const $ = exports.$; // eslint-disable-line

  exports.Decidim = exports.Decidim || {};
  const MapController = exports.Decidim.MapController;

  $(() => {
    let $mapElements = $("[data-decidim-map]");
    let supportLegacy = false;
    if ($mapElements.length < 1) {
      // @deprecated Legacy maps support
      $mapElements = $("#map");
      supportLegacy = true;
    }

    $mapElements.each((_i, el) => {
      const $map = $(el);
      const mapId = $map.attr("id");

      if (supportLegacy) {
        exports.Decidim.legacyMapSupport($map);
      }

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

      if (supportLegacy) {
        exports.Decidim.currentMap = map;
      }
    });
  });
})(window);
