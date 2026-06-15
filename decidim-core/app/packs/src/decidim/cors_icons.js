/**
 * Loads the SVG icons sprite referenced by `Decidim.config.get("icons_path")`
 * and inserts it as the first child of the document body, so the icons defined
 * in the sprite can be referenced from anywhere in the page.
 *
 * This previously lived as an inline script in the `_cors.html.erb` layout
 * partial, which is rendered in the public, admin and system layouts. It was
 * moved here (loaded by the `decidim_core` entrypoint, which is present in all
 * three contexts) to allow removing `unsafe-inline` from the CSP `script-src`.
 *
 * The request is run on `turbo:load` so `window.Decidim.config` and the DOM are
 * ready, matching the original render-time ordering. `icons_path` points to a
 * trusted internal sprite; the same serialization as the original is preserved.
 *
 * The `#svg-cors-container` element is only rendered by the `_cors.html.erb`
 * partial when CORS is enabled, so its absence is the signal to do nothing,
 * mirroring the original script that only ran inside that partial.
 */

document.addEventListener("turbo:load", () => {
  const div = document.getElementById("svg-cors-container");
  if (!div) {
    return;
  }

  Rails.ajax({
    url: window.Decidim.config.get("icons_path"),
    type: "get",
    success: (data) => {
      div.innerHTML = new XMLSerializer().serializeToString(data.documentElement);
      document.body.insertBefore(div, document.body.childNodes[0]);
    }
  });
});
