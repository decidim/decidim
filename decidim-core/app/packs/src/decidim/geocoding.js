import AutoComplete from "src/decidim/autocomplete";

$(() => {
  $("[data-decidim-geocoding]").each((_i, el) => {
    const $input = $(el);

    const autoComplete = new AutoComplete(el, {
      mode: "single",
      dataMatchKeys: ["value"],
      dataSource: (query, callback) => {
        $input.trigger("geocoder-suggest.decidim", [query, callback]);
      }
    });
    el.addEventListener("selection", autoComplete);

    $input.on("selection", (event) => {
      const selectedItem = event.detail.selection.value;
      $input.trigger("geocoder-suggest-select.decidim", [selectedItem]);

      // Not all geocoding autocomplete APIs include the coordinates in the
      // suggestions response. Therefore, some APIs may require additional
      // query for the coordinates, which should trigger this event for the
      // input element.
      if (selectedItem.coordinates) {
        $input.trigger("geocoder-suggest-coordinates.decidim", [selectedItem.coordinates]);
      }
    });
  });
});
