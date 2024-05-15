/* eslint-disable require-jsdoc */

/**
 * If you want to disable the warning but indicate that the link is an external
 * link, please define the `data-external-link-warning="false"` attribute for
 * the link,
 * e.g. <a href="https://..." target="_blank" data-external-link="text-only" data-external-domain-link="false">...</a>
 *
 * @param {HTMLElement} element The element for which to replace the link href for.
 * @returns {void} Nothing
 */
export default function updateExternalDomainLinks(element) {
  if (window.location.pathname === "/link") {
    return;
  }

  if (!element.hasAttribute("href") || element.closest(".editor-container")) {
    return;
  }

  if (element.dataset.externalDomainLink === "false") {
    return;
  }

  const parts = element.href.match(/^(([a-z]+):)?\/\/([^/:]+)(:[0-9]*)?(\/.*)?$/) || null;
  if (!parts) {
    return;
  }

  const domain = parts[3].replace(/^www\./, "")
  const allowlist = window.Decidim.config.get("external_domain_allowlist") || []
  if (allowlist.includes(domain)) {
    return;
  }

  const externalHref = `/link?external_url=${encodeURIComponent(element.href)}`;
  element.href = externalHref;
  element.dataset.remote = true
}
