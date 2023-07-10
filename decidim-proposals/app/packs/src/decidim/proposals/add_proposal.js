import attachGeocoding from "src/decidim/geocoding/attach_input"
import getCoordinateInputName from "src/decidim/geocoding/coordinate_input";

$(() => {
  const $map = $("#address_map");
  const $addressInputField = $("[data-decidim-geocoding]");

  if ($map.length) {
    $map.hide();
    $addressInputField.on("geocoder-suggest-coordinates.decidim", () => $map.show());

    let latFieldName = "latitude";
    let longFieldName = "longitude";

    if ($addressInputField.length > 0) {
      latFieldName = getCoordinateInputName("latitude", $addressInputField, {})
      longFieldName = getCoordinateInputName("longitude", $addressInputField, {})
    }

    const ctrl = $("[data-decidim-map]").data("map-controller");
    ctrl.setEventHandler("coordinates", (ev) => {
      $(`input[name='${latFieldName}']`).val(ev.lat);
      $(`input[name='${longFieldName}']`).val(ev.lng);
    });

    attachGeocoding($addressInputField, null, (coordinates) => {
      // Remove previous marker when user updates address in address field
      ctrl.removeMarker();
      ctrl.addMarker({
        latitude: coordinates[0],
        longitude: coordinates[1],
        address: $addressInputField.val()
      });
    });
  }
});
