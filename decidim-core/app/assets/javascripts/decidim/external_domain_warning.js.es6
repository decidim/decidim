((exports) => {
  $(() => {
    const currentDomain = window.location.hostname
    const whitelist = exports.Decidim.config.get("external_domain_whitelist").concat(currentDomain);

    if (window.location.pathname === "/link") {
      return;
    }

    $(() => {
      $("a").attr("href", (_n, href) => {
        if (!href) {
          return "";
        }

        if (["#", "/"].includes(href[0])) {
          return href;
        }

        const parts = href.match(/^(([a-z]+):)?\/\/([^/]+)(\/.*)?$/)
        const domain = parts[3].replace(/^www\./, "")
        if (whitelist.includes(domain)) {
          return href;
        }
        // return  `${currentDomainAndPort}/link?external_link=${link}`
        return  `/link?external_link=${href}`
      });
    });
  });
})(window)
