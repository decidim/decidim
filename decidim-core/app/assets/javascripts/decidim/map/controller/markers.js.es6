((exports) => {
  exports.Decidim = exports.Decidim || {};

  const MapController = exports.Decidim.MapController;

  class MapMarkersController extends MapController {
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
        this.markerClusters = L.markerClusterGroup();
        this.map.addLayer(this.markerClusters);
      }

      // Pre-compiles the template
      $.template(
        this.config.popupTemplateId,
        $(`#${this.config.popupTemplateId}`).html()
      );

      const bounds = new L.LatLngBounds(
        markersData.map(
          (markerData) => [markerData.latitude, markerData.longitude]
        )
      );

      markersData.forEach((markerData) => {
        let marker = L.marker([markerData.latitude, markerData.longitude], {
          icon: this.createIcon(),
          keyboard: true,
          title: markerData.title
        });
        let node = document.createElement("div");

        $.tmpl(this.config.popupTemplateId, markerData).appendTo(node);
        marker.bindPopup(node, {
          maxwidth: 640,
          minWidth: 500,
          keepInView: true,
          className: "map-info"
        }).openPopup();

        this.markerClusters.addLayer(marker);
      });

      this.map.fitBounds(bounds, { padding: [100, 100] });
    }

    clearMarkers() {
      this.map.removeLayer(this.markerClusters);
      this.markerClusters = L.markerClusterGroup();
      this.map.addLayer(this.markerClusters);
    }
  }

  exports.Decidim.MapMarkersController = MapMarkersController;
})(window);
