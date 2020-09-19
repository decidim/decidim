// = require decidim/geocoding
// = require_self

/**
 * For the available address format keys, refer to:
 * https://developer.here.com/documentation/geocoder-autocomplete/dev_guide/topics/resource-type-response-suggest.html
 */
((exports) => {
  const $ = exports.$; // eslint-disable-line

  exports.Decidim = exports.Decidim || {};

  $(() => {
    const generateAddressLabel = exports.Decidim.geocodingFormatAddress;

    $("[data-decidim-geocoding]").each((_i, el) => {
      const $input = $(el);
      const config = $input.data("decidim-geocoding");
      const queryMinLength = config.queryMinLength || 2;
      const addressFormat = config.addressFormat || [
        ["street", "houseNumber"],
        "district",
        "city",
        "county",
        "state",
        "country"
      ];
      const language = $("html").attr("lang");
      let currentSuggestionQuery = null;

      if (!config.apiKey || config.apiKey.length < 1) {
        return;
      }

      $input.on("geocoder-suggest.decidim", (_ev, query, callback) => {
        clearTimeout(currentSuggestionQuery);

        // Do not trigger API calls on short queries
        if (`${query}`.trim().length < queryMinLength) {
          return;
        }

        currentSuggestionQuery = setTimeout(() => {
          $.ajax({
            method: "GET",
            url: "https://autocomplete.geocoder.ls.hereapi.com/6.2/suggest.json",
            data: {
              apiKey: config.apiKey,
              query: query,
              language: language
            },
            dataType: "json"
          }).done((resp) => {
            if (resp.suggestions) {
              return callback(resp.suggestions.map((item) => {
                const label = generateAddressLabel(item.address, addressFormat);

                return {
                  key: label,
                  value: label,
                  locationId: item.locationId
                }
              }));
            }
            return null;
          });
        }, 200);
      });

      $input.on("geocoder-suggest-select.decidim", (_ev, selectedItem) => {
        $.ajax({
          method: "GET",
          url: "https://geocoder.ls.hereapi.com/6.2/geocode.json",
          data: {
            apiKey: config.apiKey,
            gen: 9,
            jsonattributes: 1,
            locationid: selectedItem.locationId
          },
          dataType: "json"
        }).done((resp) => {
          if (!resp.response || !Array.isArray(resp.response.view) ||
            resp.response.view.length < 1
          ) {
            return;
          }

          const view = resp.response.view[0];
          if (!Array.isArray(view.result) || view.result.length < 1) {
            return;
          }

          const result = view.result[0];
          const coordinates = [
            result.location.displayPosition.latitude,
            result.location.displayPosition.longitude
          ];

          $input.trigger(
            "geocoder-suggest-coordinates.decidim",
            [coordinates]
          );
        });
      });
    })
  });
})(window);
