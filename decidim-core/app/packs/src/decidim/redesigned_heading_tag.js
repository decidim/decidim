/**
 * Ensures the aside heading tag is transformed to h2 or h1 if the drawer is shown or hidden
 * @param {HTMLElement} node target node
 * @returns {void}
 */
export default function(node = document) {
  const element = document.querySelector("aside [data-heading-tag]")
  if (element) {
    let tagName = "H1";
    if (node.querySelector("[data-drawer]")) {
      tagName = "H2";
    }

    const newItem = document.createElement(tagName);
    newItem.className = element.className;
    newItem.dataset.headingTag = element.dataset.headingTag;
    newItem.innerHTML = element.innerHTML;
    element.parentNode.replaceChild(newItem, element);
  }
}
