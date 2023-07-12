/* eslint-disable require-jsdoc */

export default function updateExternalDomainLinks(element) {
  if (window.location.pathname === "/link") {
    return;
  }

  if (!element.hasAttribute("href") || element.closest(".editor-container")) {
    return;
  }

  const parts = element.href.match(/^(([a-z]+):)?\/\/([^/:]+)(:[0-9]*)?(\/.*)?$/) || null;
  if (!parts) {
    return;
  }

  const domain = parts[3].replace(/^www\./, "")
  const whitelist = window.Decidim.config.get("external_domain_whitelist") || []
  if (whitelist.includes(domain)) {
    return;
  }

  const externalHref = `/link?external_url=${encodeURIComponent(element.href)}`;
  element.href = externalHref;
  element.dataset.remote = true
}
