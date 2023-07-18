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
export default async function icon(iconKey, attributes = {}) {
  const iconAttributes = { ...DEFAULT_ATTRIBUTES, ...attributes };
  const htmlAttributes = { width: "0.75em", height: "0.75em" };

  Object.keys(iconAttributes).forEach((key) => {
    // Convert the key to dash-format.
    const newKey = key.replace(/([A-Z])/g, (ucw) => `-${ucw[0].toLowerCase()}`);
    if (typeof htmlAttributes[key] === "undefined") {
      htmlAttributes[newKey] = iconAttributes[key];
    } else {
      htmlAttributes[newKey] = `${htmlAttributes[newKey]} ${iconAttributes[key]}`;
    }
  });

  const { default: path } = await import(`../../images/decidim/icons/${iconKey}.svg`)
  const file = await fetch(path).then((response) => response.text())

  const placeholder = document.createElement("div")
  placeholder.innerHTML = file;
  Object.entries(htmlAttributes).forEach(([key, value]) => placeholder.firstElementChild.setAttribute(key, value))

  return placeholder.firstElementChild.outerHTML;
}
