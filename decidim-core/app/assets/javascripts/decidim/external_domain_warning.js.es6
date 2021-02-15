((exports) => {
  $(() => {
    const currentDomain = window.location.hostname
    const whitelist = exports.Decidim.config.get("external_domain_whitelist").concat(currentDomain);

    if (window.location.pathname === "/link") {
      return;
    }

    $(() => {
      $("a").filter((_i, link) => {
        const $link = $(link);
        const parts = $link.attr("href").match(/^(([a-z]+):)?\/\/([^/]+)(\/.*)?$/);
        if (!parts) {
          return false;
        }

        const domain = parts[3].replace(/^www\./, "")
        if (whitelist.includes(domain)) {
          return false;
        }

        $link.data("external-link", {
          protocol: parts[2],
          domain: parts[3],
          path: parts[4]
        });

        return true;
      }).each((_n, link) => {
        const $link = $(link);
        const externalHref = `/link?external_link=${encodeURIComponent($link.attr("href"))}`;
        $link.attr("href", externalHref)
      });
    });
  });
})(window)
