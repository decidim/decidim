/**
 * Get coordinate input name from a given $input
 * @param {string} coordinate - Allows to find 'latitude' or 'longitude' field.
 * @param {jQuery} $input - Address input field
 * @param {Object} options (optional) - Extra options
 * @returns {string} - Returns input name
 */
export default function getCoordinateInputName(coordinate, $input, options) {
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
