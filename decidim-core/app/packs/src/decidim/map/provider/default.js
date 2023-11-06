import "leaflet"

/**
 * NOTE:
 * This has to load before decidim/map in order for it to apply correctly when
 * the map is initialized. The document.ready handler set by this script has to
 * be registered before decidim/map registers its own.
 */
$(() => {
  $("[data-decidim-map]").on("configure.decidim", (_ev, map, mapConfig) => {
    const tilesConfig = mapConfig.tileLayer;
    L.tileLayer(tilesConfig.url, tilesConfig.options).addTo(map);
  });
});
