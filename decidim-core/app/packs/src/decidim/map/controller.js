// TODO-blat: where does this file comes from?
// = require jquery-tmpl
import * as L from "leaflet";
import './icon'
import MapControllerRegistry from './controller_registry'

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
