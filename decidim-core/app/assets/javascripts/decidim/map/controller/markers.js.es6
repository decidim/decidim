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

      const updateCoordinates = (data) => {
        $('input[data-type="latitude"]').val(data.lat);
        $('input[data-type="longitude"]').val(data.lng);
      };

      const bounds = new L.LatLngBounds(
        markersData.map(
          (markerData) => [markerData.latitude, markerData.longitude]
        )
      );

      markersData.forEach((markerData) => {
        let marker = L.marker([markerData.latitude, markerData.longitude], {
          icon: this.createIcon(),
          keyboard: true,
          title: markerData.title,
          draggable: markerData.draggable
        });

        if (markerData.draggable) {
          updateCoordinates({
            lat: markerData.latitude,
            lng: markerData.longitude
          });
          marker.on("drag", (ev) => {
            updateCoordinates(ev.target.getLatLng());
          });
        } else {
          let node = document.createElement("div");

          $.tmpl(this.config.popupTemplateId, markerData).appendTo(node);

          marker.bindPopup(node, {
            maxwidth: 640,
            minWidth: 500,
            keepInView: true,
            className: "map-info"
          }).openPopup();
        }

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
      this.map.removeLayer(this.markerClusters);
      this.markerClusters = L.markerClusterGroup();
      this.map.addLayer(this.markerClusters);
    }
  }

  exports.Decidim.MapMarkersController = MapMarkersController;
})(window);
