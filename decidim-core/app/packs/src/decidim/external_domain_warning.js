
/**
 * Changes all external links to point to the external domain warning page.
 * It will apply to all a[target="_blank"] found in the document, except for:
 * - the ones that are inside an editor, i.e. inside a div with class "editor-container"
 * - the ones with a domain whitelisted in the external_domain_whitelist config.
 *
 * This behaviour can be omitted adding data-external-domain-link="false" attribute to the anchor tag
 * e.g. <a href="https://..." target="_blank" data-external-domain-link="false">...</a>
 */
export default class ExternalDomainLink {
  constructor(node) {
    this.setup(node);
  }

  setup(node) {
    if (window.location.pathname === "/link") {
      return;
    }

    if (this.isNodeInEditor(node)) {
      return;
    }

    if (!node.hasAttribute("href")) {
      return;
    }

    // We use the href attribute (`node.getAttribute("href")`) instead of the
    // `node.href` property because the latter returns the URL with a trailing
    // slash, which is not what we want.
    const url = node.getAttribute("href");
    const parts = url.match(/^(([a-z]+):)?\/\/([^/:]+)(:[0-9]*)?(\/.*)?$/) || null;
    if (!parts) {
      return;
    }

    const domain = parts[3].replace(/^www\./, "")
    if (this.whitelistedDomains().includes(domain)) {
      return;
    }

    const externalHref = `/link?external_url=${encodeURIComponent(url)}`;
    node.setAttribute("href", externalHref);
    node.setAttribute("data-remote", true);
  }

  isNodeInEditor(node) {
    const EDITOR_CONTAINER_SELECTOR = ".editor-container";
    let result = false;

    document.querySelectorAll(EDITOR_CONTAINER_SELECTOR).forEach((editorNode) => {
      editorNode.querySelectorAll("a").forEach((childEditorNode) => {
        if (node === childEditorNode) {
          result = true;
        }
      });
    });

    return result;
  }

  whitelistedDomains() {
    return window.Decidim.config.get("external_domain_whitelist") || []
  }
}
