import { map, DivIcon, point } from "leaflet";
import "src/decidim/map/icon"
import MapControllerRegistry from "src/decidim/map/controller_registry"

export default class MapController {
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
    this.eventHandlers = {};

    MapControllerRegistry.setController(mapId, this);
  }

  getConfig() {
    return this.config;
  }

  getMap() {
    return this.map;
  }

  load() {
    this.map = map(this.mapId);

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
    return new DivIcon.SVGIcon.DecidimIcon({
      fillColor: this.config.markerColor,
      iconSize: point(28, 36)
    });
  }

  setEventHandler(name, callback) {
    this.eventHandlers[name] = callback;
  }

  triggerEvent(eventName, payload) {
    const handler = this.eventHandlers[eventName];
    if (typeof handler === "function") {
      return Reflect.apply(handler, this, payload);
    }
    return null;
  }
}
