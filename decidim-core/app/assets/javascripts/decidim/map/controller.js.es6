// = require jquery-tmpl
// = require decidim/map/icon
// = require_self

((exports) => {
  const $ = exports.$; // eslint-disable-line
  const L = exports.L; // eslint-disable-line

  const CONTROLLER_REGISTRY = {};

  class MapControllerRegistry {
    static getController(mapId) {
      return CONTROLLER_REGISTRY[mapId];
    }

    static setController(mapId, map) {
      CONTROLLER_REGISTRY[mapId] = map;
    }

    static findByMap(map) {
      return Object.values(CONTROLLER_REGISTRY).find((ctrl) => {
        return ctrl.getMap() === map;
      });
    }
  }

  class MapController {
    constructor(mapId, config) {
      // Remove the old map if there is already one with the same ID.
      const old = MapControllerRegistry.getController(mapId);
      if (old) {
        old.remove();
      }

      this.mapId = mapId;
      this.config = $.extend({
        popupTemplateId: "marker-popup",
        markerColor: "#ef604d"
      }, config);

      this.map = null;

      MapControllerRegistry.setController(mapId, this);
    }

    getConfig() {
      return this.config;
    }

    getMap() {
      return this.map;
    }

    load() {
      this.map = L.map(this.mapId);

      this.map.scrollWheelZoom.disable();

      // Fix the keyboard navigation on the map
      this.map.on("popupopen", (ev) => {
        const $popup = $(ev.popup.getElement());
        $popup.attr("tabindex", 0).focus();
      });
      this.map.on("popupclose", (ev) => {
        $(ev.popup._source._icon).focus();
      });

      return this.map;
    }

    // Override this in the specific map controllers.
    start() {}

    remove() {
      if (this.map) {
        this.map.remove();
        this.map = null;
      }
    }

    createIcon() {
      return new L.DivIcon.SVGIcon.DecidimIcon({
        fillColor: this.config.markerColor,
        iconSize: L.point(28, 36)
      });
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.MapController = MapController;
  exports.Decidim.MapControllerRegistry = MapControllerRegistry;
})(window);
