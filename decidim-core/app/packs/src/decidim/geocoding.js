import AutoComplete from "src/decidim/autocomplete"

$(() => {
  $("[data-decidim-geocoding]").each((_i, el) => {
    const $input = $(el);

    const autoComplete = new AutoComplete(el, {
      dataMatchKeys: ["value"],
      dataSource: (query, callback) => {
        $input.trigger("geocoder-suggest.decidim", [query, callback]);
      }
    });

    $input.on("selection", (event) => {
      const selection = event.detail.selection;
      $input.trigger("geocoder-suggest-select.decidim", [selection.value]);
      autoComplete.setInput(selection.value.key);

      // Not all geocoding autocomplete APIs include the coordinates in the
      // suggestions response. Therefore, some APIs may require additional
      // query for the coordinates, which should trigger this event for the
      // input element.
      if (selection.value.coordinates) {
        $input.trigger("geocoder-suggest-coordinates.decidim", [selection.value.coordinates]);
      }
    });
  });

  $("[data-decidim-geocoding]").on("open close", (event) => {
    event.stopPropagation();
  });
});
