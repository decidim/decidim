import createTooltip from "src/decidim/tooltips"

/**
 * Given the following HTML structure,
 * <span data-remote-tooltip="true" tooltip-url="some url" data-author="true">
 *   <span></span>
 * </span>
 *
 * This function will check if the HTMLElement where is attached to has a child, and will add a data tooltip attribute
 * to the respective child in order to attach the fetched HTML content fetched under a json key as the content of the
 * HTML tooltip. The DOM structure is expected to be like follows:
 *
 * <span data-remote-tooltip="true" tooltip-url="some url" data-author="true">
 *   <span data-tooltip="HTML content from json data field"></span>
 * </span>
 *
 * @param {HTMLElement} node The element holding the initialization data
 * @returns {void}
 */
export default async function(node) {
  const container = node.firstElementChild;

  if (container) {
    const response = await fetch(node.dataset.tooltipUrl, {
      headers: {
        "Content-Type": "application/json"
      }
    });
    if (response.ok) {
      const json = await response.json();

      container.dataset.tooltip = json.data;
      createTooltip(container);
    } else {
      console.error(response.status, response.statusText);
    }
  }
}
