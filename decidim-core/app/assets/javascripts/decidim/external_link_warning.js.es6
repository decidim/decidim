((exports) => {
  $(() => {
    const currentDomain = window.location.host
    const whitelist = exports.Decidim.config.get("external_domain_whitelist");
    console.log("whitelist", whitelist)

    if (window.location.pathname === "/link") {
      return;
    }

    $(() => {
      $("a").attr("href", (_n, link) => {
        if (!link) {
          console.log("not a link")
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
        return  `${currentDomain}/link?external_link=${link}`
      });
    });
  });
})(window)
