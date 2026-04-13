import MapController from "src/decidim/map/controller"
import "leaflet.markercluster";

export default class MapMarkersController extends MapController {
  start() {
    this.markerClusters = null;

    if (Array.isArray(this.config.markers) && this.config.markers.length > 0) {
      this.addMarkers(this.config.markers);
    } else {
      this.map.fitWorld();
    }
  }

  addMarkers(markersData) {
    if (this.markerClusters === null) {
      this.markerClusters = new L.MarkerClusterGroup();
      this.map.addLayer(this.markerClusters);
    }

    const template = document.getElementById(this.config.popupTemplateId);
    if (!template) {
      return;
    }

    const bounds = new L.LatLngBounds(
      markersData.map(
        (markerData) => [markerData.latitude, markerData.longitude]
      )
    );

    markersData.forEach((markerData) => {
      let marker = new L.Marker([markerData.latitude, markerData.longitude], {
        icon: this.createIcon(),
        keyboard: true,
        title: markerData.title
      });

      let node = document.createElement("div");
      const clone = template.content.cloneNode(true);

      const linkEl = clone.querySelector("[data-link]");
      if (linkEl) {
        linkEl.setAttribute("href", markerData.link);
      }

      const titleEl = clone.querySelector("[data-title]");
      if (titleEl) {
        titleEl.textContent = markerData.title;
      }

      const itemsEl = clone.querySelector("[data-items]");
      if (itemsEl && markerData.items) {
        let items = markerData.items;
        if (typeof items === "string") {
          try {
            items = JSON.parse(items);
          } catch (error) {
            items = [];
          }
        }
        items.forEach((item) => {
          const span = document.createElement("span");
          if (item.icon) {
            span.innerHTML = item.icon;
          }
          const textWrapper = document.createElement("span");
          textWrapper.innerHTML = item.text;
          span.appendChild(textWrapper);
          itemsEl.appendChild(span);
        });
      }

      node.appendChild(clone);
      marker.bindPopup(node, {
        maxWidth: this.map.getSize().x * 0.8,
        keepInView: true,
        closeButton: false
      }).openPopup();

      this.markerClusters.addLayer(marker);
    });

    // Make sure there is enough space in the map for the padding to be
    // applied. Otherwise the map will automatically zoom out (test it on
    // mobile). Make sure there is at least the same amount of width and
    // height available on both sides + the padding (i.e. 4x padding in
    // total).
    const size = this.map.getSize();
    if (size.y >= 400 && size.x >= 400) {
      this.map.fitBounds(bounds, { padding: [100, 100] });
    } else if (size.y >= 120 && size.x >= 120) {
      this.map.fitBounds(bounds, { padding: [30, 30] });
    } else {
      this.map.fitBounds(bounds);
    }
  }

  clearMarkers() {
    if (this.markerClusters !== null) {
      this.map.removeLayer(this.markerClusters);
    }
    this.markerClusters = new L.MarkerClusterGroup();
    this.map.addLayer(this.markerClusters);
  }
}
