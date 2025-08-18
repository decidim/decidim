import icon from "src/decidim/icon"

const DEFAULT_MESSAGES = {
  externalLink: "External link",
  opensInNewTab: "Opens in new tab"
};
let MESSAGES = DEFAULT_MESSAGES;

/**
 * Appends an icon to distinguish those links pointing out of decidim.
 * It will apply to all a[target="_blank"] found in the document
 *
 * This behaviour can be omitted adding data-external-link="false" attribute to the anchor tag
 * e.g. <a href="https://..." target="_blank" data-external-link="false">...</a>
 *
 * If you do not want to display the external link indicator, you still need to indicate that
 * the link opens in a new tab to the screen readers. This can be done by adding
 * data-external-link="text-only" attribute to the anchor tag,
 * e.g. <a href="https://..." target="_blank" data-external-link="text-only">...</a>
 *
 * In addition, if you want to disable the external link warning for the link, you can add the
 * data-external-domain-link="false" attribute to the anchor tag,
 * e.g. <a href="https://..." target="_blank" data-external-link="text-only" data-external-domain-link="false">...</a>
 */
export default class ExternalLink {
  static configureMessages(messages) {
    MESSAGES = { ...DEFAULT_MESSAGES, ...messages };
  }

  constructor(node) {
    if (node.closest(".editor-container")) {
      return;
    }

    if (!node.querySelector("span[data-external-link]")) {
      if (node.dataset.externalLink === "text-only") {
        this.setupTextOnly(node);
      } else {
        this.setup(node);
      }
    }
  }

  setup(node) {
    const span = document.createElement("span");

    span.dataset.externalLink = true;
    span.innerHTML = `${this.generateIcon()}${this.generateScreenReaderLabel(node)}`
    span.classList.add("inline-block", "mx-0.5");

    return node.appendChild(span);
  }

  setupTextOnly(node) {
    const dummy = document.createElement("span");
    dummy.innerHTML = this.generateScreenReaderLabel(node);

    return node.appendChild(dummy.firstChild);
  }

  generateIcon() {
    return icon("external-link-line", { class: "fill-current" });
  }

  generateScreenReaderLabel(node) {
    let text = MESSAGES.opensInNewTab;
    if (this._isExternalLink(node)) {
      text = MESSAGES.externalLink;
    }

    return `<span class="sr-only">(${text})</span>`;
  }

  _isExternalLink(node) {
    const externalMatches = [
      // Links to the internal link page /link?external_url=https%3A%2F%2Fdecidim.org
      new RegExp("^/link\\?external_url="),
      // Links starting with http/s and not to the current host
      new RegExp(`^https?://((?!${location.host}).)+`)
    ];

    const href = node.getAttribute("href") || "";
    return externalMatches.some(((regexp) => href.match(regexp)));
  }
}
