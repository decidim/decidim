/**
 * Loads the SVG icons sprite referenced by `Decidim.config.get("icons_path")`
 * and inserts it as the first child of the document body, so the icons can be
 * referenced from anywhere in the page. The `#svg-cors-container` element is
 * only rendered (by the `_cors.html.erb` layout partial) when CORS is enabled,
 * so its absence is the signal to do nothing.
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
