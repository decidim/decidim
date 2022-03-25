import icon from "src/decidim/icon"

const EXCLUDE_CLASSES = [
  "card--list__data__icon",
  "footer-social__icon",
  "logo-cityhall"
];
const EXCLUE_ANCESTORS_CLASSES = [
  "editor-container"
]
const EXCLUDE_REL = ["license", "decidim"];

const DEFAULT_MESSAGES = {
  externalLink: "External link"
};
let MESSAGES = DEFAULT_MESSAGES;

export default class ExternalLink {
  static configureMessages(messages) {
    MESSAGES = $.extend(DEFAULT_MESSAGES, messages);
  }

  constructor(link) {
    this.$link = link;

    this.setup();
  }

  setup() {
    if (EXCLUDE_CLASSES.some((cls) => this.$link.hasClass(cls))) {
      return;
    }
    if (EXCLUE_ANCESTORS_CLASSES.some((cls) => this.$link.parents().hasClass(cls))) {
      return;
    }
    if (
      EXCLUDE_REL.some((rel) => {
        const linkRels = `${this.$link.attr("rel")}`.split(" ");
        return linkRels.indexOf(rel) > -1;
      })
    ) {
      return;
    }

    this.$link.addClass("external-link-container");
    let spacer = "&nbsp;";
    if (this.$link.text().trim().length < 1) {
      // Fixes image links extra space
      spacer = "";
    }
    this.$link.append(`${spacer}${this.generateElement()}`);
  }

  generateElement() {
    let content = `${this.generateIcon()}${this.generateScreenReaderLabel()}`;

    return `<span class="external-link-indicator">${content}</span>`;
  }

  generateIcon() {
    return icon("external-link");
  }

  generateScreenReaderLabel() {
    return `<span class="show-for-sr">(${MESSAGES.externalLink})</span>`;
  }
}
