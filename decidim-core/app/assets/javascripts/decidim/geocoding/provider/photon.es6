// = require decidim/geocoding
// = require_self

((exports) => {
  const $ = exports.$; // eslint-disable-line

  $(() => {
    $("[data-decidim-geocoding]").each((_i, el) => {
      const $input = $(el);
      const config = $input.data("decidim-geocoding");
      const language = $("html").attr("lang");
      let currentSuggestionQuery = null;

      if (!config.url || config.url.length < 1) {
        return;
      }

      const compact = (items) => items.filter(
        (part) => part !== null && typeof part !== "undefined" && `${part}`.trim().length > 0
      );

      $input.on("geocoder-suggest.decidim", (_ev, query, callback) => {
        clearTimeout(currentSuggestionQuery);
        currentSuggestionQuery = setTimeout(() => {
          $.ajax({
            method: "GET",
            url: config.url,
            data: {
              q: query, // eslint-disable-line
              lang: language
            },
            dataType: "json"
          }).done((resp) => {
            if (resp.features) {
              return callback(resp.features.map((item) => {
                const streetParts = [
                  item.properties.street,
                  item.properties.housenumber
                ];
                const labelParts = [
                  item.properties.name,
                  compact(streetParts).join(" "),
                  item.properties.postcode,
                  item.properties.city,
                  item.properties.state,
                  item.properties.country
                ];
                const label = compact(labelParts).join(", ");

                return {
                  key: label,
                  value: label,
                  coordinates: item.geometry.coordinates
                }
              }));
            }
            return null;
          });
        }, 200);
      });
    })
  });
})(window);
