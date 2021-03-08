((exports) => {
  const $ = exports.$; // eslint-disable-line

  const getCoordinateInputName = (coordinate, $input, options) => {
    const key = `${coordinate}Name`;
    if (options[key]) {
      return options[key];
    }

    const inputName = $input.attr("name");
    const subNameMatch = /\[[^\]]+\]$/;
    if (inputName.match(subNameMatch)) {
      return inputName.replace(subNameMatch, `[${coordinate}]`);
    }

    return coordinate;
  }

  /**
   * You can use this method to "attach" front-end geocoding to any forms in the
   * front-end which have address fields with geocoding autocompletion
   * functionality already applied to them.
   *
   * To learn more about the front-end geocoding autocompletion, please refer to
   * the maps documentation at: /docs/customization/maps.md.
   *
   * When the geocoding autocompletion finishes, most of the times, its results
   * will also contain the geocoordinate information for the selected address.
   * This method allows you to pass these coordinates (latitude and longitude)
   * to the same front-end form where the geocoding autocompletion address field
   * is located at (which is the $input you pass to this method). The latitude
   * and longitude coordinates will be added or "attached" to the form once the
   * user selects one of the suggested addresses.
   *
   * Therefore, if there was the following geocoding autocompletion field at
   * your form:
   *   <input
   *     id="record_address"
   *     type="text"
   *     name="record[address]"
   *     data-decidim-geocoding="{&quot;url&quot;:&quot;https://photon.example.org/api/&quot;}"
   *   />
   *
   * You would then "attach" the geocoding result coordinates to the same form
   * where this input is at as follows:
   *   $(document).ready(function() {
   *     window.Decidim.attachGeocoding($("#record_address"));
   *   });
   *
   * Now, after the user selects one of the suggested geocoding autocompletion
   * addresses and the geocoding autocompletion API provides the coordinates in
   * the results, you would have the following fields automatically generated
   * to your form:
   *   <input id="record_address" type="text" name="record[address]" value="Selected address, 00210, City" ... />
   *   <input id="record_latitude" type="hidden" name="record[latitude]" value="1.123" />
   *   <input id="record_longitude" type="hidden" name="record[longitude]" value="2.234" />
   *
   * If you would not do the attachment, these hidden longitude and latitude
   * fields would not be generated and the geocoding would have to happen at the
   * server-side when the form is submitted. The problem with that approach
   * would be that the server-side address geocoding could potentially result in
   * different coordinates than what the user actually selected in the front-end
   * because the autocompletion API can return different coordinates than the
   * geocoding API. Another reason is to avoid unnecessary calls to the
   * geocoding API as the front-end geocoding suggestion already returned the
   * coordinate values we need.
   *
   * @param {jQuery} $input The input jQuery element for the geocoded address
   *   field.
   * @param {Object} options (optional) Extra options if you want to customize
   *   the latitude and longitude element IDs or names from the default.
   * @returns {void}
   */
  const attachGeocoding = ($input, options) => {
    const attachOptions = $.extend({}, options);
    const inputIdParts = $input.attr("id").split("_");
    inputIdParts.pop();

    const idPrefix = `${inputIdParts.join("_")}`;
    const config = $.extend({
      latitudeId: `${idPrefix}_latitude`,
      longitudeId: `${idPrefix}_longitude`,
      latitudeName: getCoordinateInputName("latitude", $input, attachOptions),
      longitudeName: getCoordinateInputName("longitude", $input, attachOptions)
    }, options);
    let geocoded = false;

    const createCoordinateFields = () => {
      let $latitude = $(`#${config.latitudeId}`);
      if ($latitude.length < 1) {
        $latitude = $(`<input type="hidden" name="${config.latitudeName}" id="${config.latitudeId}" />`);
        $input.after($latitude);
      }

      let $longitude = $(`#${config.longitudeId}`);
      if ($longitude.length < 1) {
        $longitude = $(`<input type="hidden" name="${config.longitudeName}" id="${config.longitudeId}" />`);
        $input.after($longitude);
      }
    }
    const clearCoordinateFields = () => {
      if (geocoded) {
        return;
      }

      $(`#${config.latitudeId}`).val("").removeAttr("value");
      $(`#${config.longitudeId}`).val("").removeAttr("value");
    };
    const setCoordinates = (coordinates) => {
      createCoordinateFields();

      $(`#${config.latitudeId}`).val(coordinates[0]).attr("value", coordinates[0]);
      $(`#${config.longitudeId}`).val(coordinates[1]).attr("value", coordinates[1]);
    }

    // When the user changes the value of the coordinate field without selecting
    // any of the geocoding autocomplete results, clear the current latitude and
    // longitude values to let the backend do the geocoding. Once a geocoding
    // autocomplete value has been selected, assume the user just wants to
    // refine the address formatting without changing the location point value.
    // If they want, they can still modify the point in the next step of the
    // proposal creation/editing.
    $input.on("change.decidim", () => {
      clearCoordinateFields();
    });

    // When we receive the geocoding event on the field, update the coordinate
    // values.
    $input.on("geocoder-suggest-coordinates.decidim", (_ev, coordinates) => {
      setCoordinates(coordinates);
      geocoded = true;
    });

    // Set the initial values if the field defines the coordinates
    const coordinates = `${$input.data("coordinates")}`.split(",").map(parseFloat);
    if (Array.isArray(coordinates) && coordinates.length === 2) {
      setCoordinates(coordinates);
    }
  };

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.attachGeocoding = attachGeocoding;
})(window);
