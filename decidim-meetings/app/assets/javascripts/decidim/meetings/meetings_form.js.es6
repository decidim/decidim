((exports) => {
  const $ = exports.$; // eslint-disable-line
  const { attachGeocoding } = exports.Decidim;

  $(() => {
    // Adds the latitude/longitude inputs after the geocoding is done
    attachGeocoding($("#meeting_address"));
  });
})(window);
