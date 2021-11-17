import AutoComplete from "./autocomplete";

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
      autoComplete.setInput(selection.value.key);
    });
  });

  $("[data-decidim-geocoding]").on("open close", (event) => {
    event.stopPropagation();
  });
});
