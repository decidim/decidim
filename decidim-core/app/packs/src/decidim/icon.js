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
  const iconAttributes = { ...DEFAULT_ATTRIBUTES, ...attributes };
  const htmlAttributes = { width: "0.75em", height: "0.75em" };

  Object.keys(iconAttributes).forEach((key) => {
    // Convert the key to dash-format.
    const newKey = key.replace(/([A-Z])/g, (ucw) => `-${ucw[0].toLowerCase()}`);
    if (typeof htmlAttributes[key] === "undefined") {
      htmlAttributes[newKey] = iconAttributes[key];
    } else if (iconAttributes[key] === null) {
      Reflect.deleteProperty(htmlAttributes, newKey);
    } else {
      htmlAttributes[newKey] = `${htmlAttributes[newKey]} ${iconAttributes[key]}`;
    }
  });

  const svg = document.createElement("svg")
  const use = document.createElement("use")
  const title = document.createElement("title")

  title.innerHTML = iconAttributes.title || iconAttributes.ariaLabel || iconKey
  use.setAttribute("href", `${window.Decidim.config.get("icons_path")}#ri-${iconKey}`)
  Object.entries(htmlAttributes).forEach(([key, value]) => svg.setAttribute(key, value))

  svg.appendChild(title)
  svg.appendChild(use)

  return svg.outerHTML;
}
