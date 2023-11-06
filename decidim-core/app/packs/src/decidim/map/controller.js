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
      markerColor: "#e02d2d"
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
    const size = 36
    return L.divIcon({
      html: `
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="${size}px" height="${size}px"><path fill="none" d="M0 0h24v24H0z"/><path fill="currentColor" d="M18.364 17.364L12 23.728l-6.364-6.364a9 9 0 1 1 12.728 0zM12 15a4 4 0 1 0 0-8 4 4 0 0 0 0 8zm0-2a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/></svg>`,
      iconAnchor: [0.5 * size, size],
      popupAnchor: [0, -0.5 * size]
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
