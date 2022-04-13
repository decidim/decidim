import { marker } from "leaflet";
import MapController from "src/decidim/map/controller"

const openLink = window.open;

export default class MapStaticController extends MapController {
  start() {
    this.map.removeControl(this.map.zoomControl);
    this.map.dragging.disable();
    this.map.touchZoom.disable();
    this.map.doubleClickZoom.disable();
    this.map.scrollWheelZoom.disable();
    this.map.boxZoom.disable();
    this.map.keyboard.disable();
    if (this.map.tap) {
      this.map.tap.disable();
    }

    if (this.config.latitude && this.config.longitude) {
      const coordinates = [this.config.latitude, this.config.longitude];

      this.map.panTo(coordinates);
      const _marker = marker(coordinates, {
        icon: this.createIcon(),
        keyboard: true,
        title: this.config.title
      }).addTo(this.map);
      _marker._icon.removeAttribute("tabindex");
    }
    if (this.config.zoom) {
      this.map.setZoom(this.config.zoom);
    } else {
      this.map.setZoom(15);
    }

    if (this.config.link) {
      this.map._container.addEventListener("click", (ev) => {
        ev.preventDefault();
        this.map._container.focus();
        openLink(this.config.link, "_blank");
      });
    }
  }
}
