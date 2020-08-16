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

      if (!config.apiKey || config.apiKey.length < 1) {
        return;
      }

      $input.on("geocoder-suggest.decidim", (_ev, query, callback) => {
        clearTimeout(currentSuggestionQuery);
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
                return {
                  key: item.label,
                  value: item.label,
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
