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

    $input.on("geocoder-suggest-coordinates.decidim", (_ev, coordinates) => {
      let $latitude = $(`#${config.latitudeId}`);
      let $longitude = $(`#${config.longitudeId}`);
      if ($latitude.length < 1) {
        $latitude = $(`<input type="hidden" name="${config.latitudeName}" id="${config.latitudeId}" />`);
        $input.after($latitude);
      }
      if ($longitude.length < 1) {
        $longitude = $(`<input type="hidden" name="${config.longitudeName}" id="${config.longitudeId}" />`);
        $input.after($longitude);
      }

      $latitude.val(coordinates[0]).attr("value", coordinates[0]);
      $longitude.val(coordinates[1]).attr("value", coordinates[1]);
    });
  };

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.attachGeocoding = attachGeocoding;
})(window);
