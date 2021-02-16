((exports) => {
  $(() => {
    const currentDomain = window.location.host
    let whitelist = exports.Decidim.config.get("external_domain_whitelist")

    if (window.location.pathname === "/link") {
      return;
    }

    if (whitelist) {
      whitelist = whitelist.concat(currentDomain)
    } else {
      whitelist = [currentDomain]
    }

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

      return true;
    }).each((_n, link) => {
      const $link = $(link);
      const externalHref = `/link?external_link=${encodeURIComponent($link.attr("href"))}`;
      $link.attr("href", externalHref)
    });
  });
})(window)
