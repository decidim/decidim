import icon from "src/decidim/redesigned_icon"

/**
 * Appends an icon to distinguish those links pointing out of decidim.
 * It will apply to all a[target="_blank"] found in the document
 *
 * This behaviour can be omitted adding data-external-link="false" attribute to the anchor tag
 * e.g. <a href="https://..." target="_blank" data-external-link="false">...</a>
 */
export default class ExternalLink {
  static configureMessages(messages) {
    this.MESSAGES = { ...this.MESSAGES, ...messages };
  }

  constructor(node) {
    this.MESSAGES = {
      externalLink: "External link"
    };

    /* REDESIGN_PENDING: this is done to avoid duplication due to the polling,
    once the addComment (decidim-comments/app/packs/src/decidim/comments/comments.component.js)
    function dispatches an event, this conditional will be no longer necessary */
    if (!node.querySelector("span[data-external-link]")) {
      this.setup(node);
    }
  }

  setup(node) {
    const span = document.createElement("span");

    span.dataset.externalLink = true;
    span.innerHTML = `${this.generateIcon()}${this.generateScreenReaderLabel()}`
    span.classList.add("inline-block", "mx-0.5");

    return node.appendChild(span);
  }

  generateIcon() {
    return icon("external-link-line", { class: "fill-current" });
  }

  generateScreenReaderLabel() {
    return `<span class="sr-only">(${this.MESSAGES.externalLink})</span>`;
  }
}
