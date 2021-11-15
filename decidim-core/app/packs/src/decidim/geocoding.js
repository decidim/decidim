import Autocomplete from "@tarekraafat/autocomplete.js";

$(() => {
  $("[data-decidim-geocoding]").each((_i, el) => {
    const $input = $(el);
    const $fieldContainer = $input.parent();
    $fieldContainer.addClass("autocomplete_search");

    const autoCompleteJS = new Autocomplete({
      selector: () => el,
      data: {
        keys: ["value"],
        src: async (query) => {
          const promise = new Promise((resolve) => {
            $input.trigger("geocoder-suggest.decidim", [query, resolve]);
          });

          const results = await promise;
          return results;
        }
      }
    });

    $input.on("selection", (event) => {
      const selection = event.detail.selection;
      autoCompleteJS.input.value = selection.value.key;
    })
  });

  $("[data-decidim-geocoding]").on("open close", (event) => {
    event.stopPropagation();
  })
});
