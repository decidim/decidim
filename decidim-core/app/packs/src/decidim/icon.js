const DEFAULT_ATTRIBUTES = {
  role: "img",
  "aria-hidden": "true"
};

/**
 * Generates a Decidim icon element and returns it as a string.
 * @param {String} iconKey - the key of the icon to be generated
 * @param {Object} attributes - extra attributes to define for the icon SVG
 * @param {int} wait - number of milliseconds to wait before executing the function.
 * @private
 * @returns {Void} - Returns nothing.
 */
export default function icon(iconKey, attributes = {}) {
  const iconAttributes = $.extend(DEFAULT_ATTRIBUTES, attributes);
  const title = iconAttributes.title || iconAttributes.ariaLabel;
  Reflect.deleteProperty(iconAttributes, "title");

  const htmlAttributes = {
    "class": `icon icon--${iconKey}`
  };
  Object.keys(iconAttributes).forEach((key) => {
    // Convert the key to dash-format.
    const newKey = key.replace(/([A-Z])/g, (ucw) => `-${ucw[0].toLowerCase()}`);
    if (typeof htmlAttributes[key] === "undefined") {
      htmlAttributes[newKey] = iconAttributes[key];
    } else {
      htmlAttributes[newKey] = `${htmlAttributes[newKey]} ${iconAttributes[key]}`;
    }
  });

  const iconsPath =  window.Decidim.config.get("icons_path");
  const elHtml = `<svg><use href="${iconsPath}#icon-${iconKey}"></use></svg>`;
  const $el = $(elHtml);
  if (title) {
    $el.prepend(`<title>${title}</title>`);
  } else {
    // This keeps accessibility audit tools happy
    $el.prepend(`<title>${iconKey}</title>`);
    // Force hidden if title is not defined
    htmlAttributes["aria-hidden"] = "true";
  }
  $el.attr(htmlAttributes);

  return $("<div />").append($el).html();
}
