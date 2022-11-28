/* eslint-disable require-jsdoc */

const EXCLUDE_CLASSES = [
  "ssb-icon"
];

const EXCLUDE_ANCESTOR_CLASSES = [
  "editor-container"
];

export default function updateExternalDomainLinks($target) {
  const whitelist = window.Decidim.config.get("external_domain_whitelist") || []

  if (window.location.pathname === "/link") {
    return;
  }

  $("a", $target).filter((_i, link) => {
    const $link = $(link);
    if (!$link[0].hasAttribute("href")) {
      return false;
    }

    if (EXCLUDE_CLASSES.some((cls) => $link.hasClass(cls))) {
      return false;
    }

    if (EXCLUDE_ANCESTOR_CLASSES.some((cls) => $link.parents().hasClass(cls))) {
      return false;
    }

    const parts = $link.attr("href").match(/^(([a-z]+):)?\/\/([^/:]+)(:[0-9]*)?(\/.*)?$/) || null;
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
    $link.attr("data-remote", true)
  });
}
