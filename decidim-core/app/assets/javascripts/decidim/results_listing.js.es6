// = require_self

((exports) => {
  const { pushState, registerCallback } = window.Decidim.History;
  const initializeListingOptionsMenu = (options) => {
    exports.$(document).on("click", `${options.containerSelector} a`, (event) => {
      const $target = $(event.target);

      $target.parents(".menu").find("a:first").text($target.text());

      pushState($target.attr("href"));
    })

    registerCallback(options.callbackName, () => {
      const url = window.location.toString();
      const match = url.match(/${options.urlParameter}=([^&]*)/);
      const $targetMenu = $(`${options.containerSelector} .menu`);
      let value = $targetMenu.find(".menu a:first").data(options.dataAttribute);

      if (match) {
        value = match[1];
      }

      const linkText = $targetMenu.find(`.menu a[data-${options.dataAttribute}="${value}"]`).text();

      $targetMenu.find("a:first").text(linkText);
    });
  };

  exports.$(() => {
    initializeListingOptionsMenu({
      containerSelector: ".order-by",
      callbackName: "orders",
      urlParameter: "order",
      dataAttribute: "order"
    });
    initializeListingOptionsMenu({
      containerSelector: ".results-per-page",
      callbackName: "results_per_page",
      urlParameter: "per_page",
      dataAttribute: "per-page-option"
    });
  });
})(window)
