((exports) => {
  const updateExternalDomainLinks = ($target) => {
    const whitelist = exports.Decidim.config.get("external_domain_whitelist")

    if (window.location.pathname === "/link") {
      return;
    }

    $("a", $target).filter((_i, link) => {
      const $link = $(link);
      const parts = $link.attr("href").match(/^(([a-z]+):)?\/\/([^/]+)(\/.*)?$/) || null;
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
      const externalHref = `/link?external_url=${encodeURIComponent($link.attr("href"))}`;
      $link.attr("href", externalHref)
    });
  }

  $(() => {
    updateExternalDomainLinks($("body"))
  });

  exports.Decidim.updateExternalDomainLinks = updateExternalDomainLinks
})(window)
