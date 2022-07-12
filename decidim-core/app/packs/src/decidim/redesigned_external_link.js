import icon from "src/decidim/icon"

export default class ExternalLink {
  static configureMessages(messages) {
    this.MESSAGES = { ...this.MESSAGES, ...messages };
  }

  constructor(node) {
    this.MESSAGES = {
      externalLink: "External link"
    };

    this.setup(node);
  }

  setup(node) {
    const span = document.createElement("span");

    span.innerHTML = `${this.generateIcon()}${this.generateScreenReaderLabel()}`
    span.classList.add("inline-block", "mx-0.5");

    return node.appendChild(span);
  }

  generateIcon() {
    return icon("external-link", { class: "w-2 h-2 fill-current" });
  }

  generateScreenReaderLabel() {
    return `<span class="sr-only">(${this.MESSAGES.externalLink})</span>`;
  }
}
