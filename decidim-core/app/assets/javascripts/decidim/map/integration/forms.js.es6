((exports) => {
  const $ = exports.$; // eslint-disable-line

  $(() => {
    $("[data-decidim-map]").on("ready.decidim", (ev, _map, mapConfig) => {
      const $map = $(ev.target);
      const ctrl = $map.data("map-controller");

      if (mapConfig.type === "drag-marker") {
        const inputSelector = $map.data("connected-input");
        if (!inputSelector) {
          return;
        }

        const $inputs = $(inputSelector);
        if ($inputs.length < 1) {
          return;
        }

        ctrl.setEventHandler("coordinates", (latlng) => {
          $inputs.each((_i, el) => {
            const $input = $(el);
            if ($input.data("type") === "latitude") {
              $input.val(latlng.lat);
            } else if ($input.data("type") === "longitude") {
              $input.val(latlng.lng);
            }
          })
        });
      }
    });
  });
})(window);
