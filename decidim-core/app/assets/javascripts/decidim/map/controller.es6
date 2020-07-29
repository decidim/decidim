// = require jquery-tmpl
// = require decidim/map/icon
// = require_self

((exports) => {
  const $ = exports.$; // eslint-disable-line
  const L = exports.L; // eslint-disable-line

  const CONTROLLER_REGISTRY = {};

  class MapControllerRegistry {
    static setController(mapId, map) {
      CONTROLLER_REGISTRY[mapId] = map;
    }

    static getController(mapId) {
      return CONTROLLER_REGISTRY[mapId];
    }

    static findByMap(map) {
      return Object.values(CONTROLLER_REGISTRY).find((ctrl) => {
        return ctrl.getMap() === map;
      });
    }
  }

  class MapController {
    constructor(mapId, settings) {
      // Remove the old map if there is already one with the same ID.
      const old = MapControllerRegistry.getController(mapId);
      if (old) {
        old.remove();
      }

      this.mapId = mapId;
      this.settings = $.extend({
        popupTemplateId: "marker-popup",
        markerColor: "#ef604d"
      }, settings);

      this.map = null;
      this.markerClusters = null;

      MapControllerRegistry.setController(mapId, this);
    }

    getSettings() {
      return this.settings;
    }

    getMap() {
      return this.map;
    }

    addMarkers(markersData) {
      // Pre-compiles the template
      $.template(
        this.settings.popupTemplateId,
        $(`#${this.settings.popupTemplateId}`).html()
      );

      const bounds = new L.LatLngBounds(
        markersData.map(
          (markerData) => [markerData.latitude, markerData.longitude]
        )
      );

      markersData.forEach((markerData) => {
        let marker = L.marker([markerData.latitude, markerData.longitude], {
          icon: new L.DivIcon.SVGIcon.DecidimIcon({
            fillColor: this.settings.markerColor
          }),
          keyboard: true,
          title: markerData.title
        });
        let node = document.createElement("div");

        $.tmpl(this.settings.popupTemplateId, markerData).appendTo(node);
        marker.bindPopup(node, {
          maxwidth: 640,
          minWidth: 500,
          keepInView: true,
          className: "map-info"
        }).openPopup();

        this.markerClusters.addLayer(marker);
      });

      this.map.addLayer(this.markerClusters);
      this.map.fitBounds(bounds, { padding: [100, 100] });
    }

    clearMarkers() {
      this.map.removeLayer(this.markerClusters);
      this.markerClusters = L.markerClusterGroup();
    }

    load() {
      this.map = L.map(this.mapId);
      this.markerClusters = L.markerClusterGroup();

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

    remove() {
      if (this.map) {
        this.map.remove();
        this.map = null;
      }
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.MapController = MapController;
  exports.Decidim.MapControllerRegistry = MapControllerRegistry;
})(window);
