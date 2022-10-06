import "src/decidim/map/factory"

$(() => {
  // Load the map controller factory method in the document.ready handler to
  // allow overriding it by any script that is loaded before the document is
  // ready.
  let $mapElements = $("[data-decidim-map]");
  if ($mapElements.length < 1 && $("#map").length > 0) {
    throw new Error(
      "DEPRECATION: Please update your maps customizations or include 'decidim/map/legacy.js' for legacy support!"
    );
  }

  $mapElements.each((_i, el) => {
    const $map = $(el);
    let mapId = $map.attr("id");
    if (!mapId) {
      mapId = `map-${Math.random().toString(36).substr(2, 9)}`;
      $map.attr("id", mapId);
    }

    const mapConfig = $map.data("decidim-map");
    const ctrl = window.Decidim.createMapController(mapId, mapConfig);
    const map = ctrl.load();

    $map.data("map", map);
    $map.data("map-controller", ctrl);

    $map.trigger("configure.decidim", [map, mapConfig]);

    ctrl.start();

    // Indicates the map is loaded with the map objects initialized and ready
    // to be used.
    $map.trigger("ready.decidim", [map, mapConfig]);
  });
});
