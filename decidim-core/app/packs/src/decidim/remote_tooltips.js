import createTooltip from "src/decidim/tooltips"

/**
 * This function is parsing the DOM and tries to attach and initialize a tooltip starting from an element
 * containing the following structure:
 * <span data-remote-tooltip="true" tooltip-url="some url" data-author="true">
 *   <span></span>
 * </span>
 *
 * @param {HTMLElement} node The element holding the initialization data
 * @returns {void}
 */
export default async function(node) {
  const container = node.firstElementChild;

  if (container) {

    try {
      const response = await fetch(node.dataset.tooltipUrl, {
        headers: {
          "Content-Type": "application/json"
        }
      });
      if (!response.ok) {
        throw new Error(`Response status: ${response.status}`);
      }

      const json = await response.json();

      container.dataset.tooltip = json.data;
      createTooltip(container);
    } catch (error) {
      console.error(error);
    }
  }
}
