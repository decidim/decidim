import attachGeocoding from "src/decidim/geocoding/attach_input"
import getCoordinateInputName from "src/decidim/geocoding/coordinate_input";

$(() => {
  const $checkbox = $("input:checkbox[name$='[has_address]']");
  const $addressInput = $("#address_input");
  const $addressInputField = $("input", $addressInput);
  const $map = $("#address_map");
  let latFieldName = "latitude";
  let longFieldName = "longitude";

  if ($addressInputField.length > 0) {
    latFieldName = getCoordinateInputName("latitude", $addressInputField, {})
    longFieldName = getCoordinateInputName("longitude", $addressInputField, {})
  }

  $map.hide();

  if ($checkbox.length > 0) {
    const toggleInput = () => {
      if ($checkbox[0].checked) {
        $addressInput.show();
        $addressInputField.prop("disabled", false);
      } else {
        $addressInput.hide();
        $addressInputField.prop("disabled", true);
      }
    }
    toggleInput();
    $checkbox.on("change", toggleInput);
  }

  if ($addressInput.length > 0) {
    if ($checkbox[0].checked) {
      $map.show();
    }

    const ctrl = $("[data-decidim-map]").data("map-controller");
    ctrl.setEventHandler("coordinates", (ev) => {
      $(`input[name='${latFieldName}']`).val(ev.lat);
      $(`input[name='${longFieldName}']`).val(ev.lng);
    });

    attachGeocoding($addressInputField, null, (coordinates) => {
      $map.show();
      // Remove previous marker when user updates address in address field
      ctrl.removeMarker();
      ctrl.addMarker({
        latitude: coordinates[0],
        longitude: coordinates[1],
        address: $addressInput.val()
      });
    });
  }
});
