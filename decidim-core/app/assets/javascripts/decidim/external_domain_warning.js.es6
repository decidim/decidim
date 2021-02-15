((exports) => {
  $(() => {
    const currentDomainAndPort = window.location.host
    const whitelist = exports.Decidim.config.get("external_domain_whitelist").concat(window.location.hostname);
    // console.log("whitelist", whitelist)

    if (window.location.pathname === "/link") {
      return;
    }

    $(() => {
      $("a").attr("href", (_n, link) => {
        if (!link) {
          return "";
        }

        if (["#", "/"].includes(link[0])) {
          return link;
        }

        const parts = link.match(/^(([a-z]+):)?\/\/([^/]+)(\/.*)?$/)
        const domain = parts[3].replace(/^www\./, "")
        if (whitelist.includes(domain)) {
          return link;
        }
        return  `${currentDomainAndPort}/link?external_link=${link}`
      });
    });
  });
})(window)
