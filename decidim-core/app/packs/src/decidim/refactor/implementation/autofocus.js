/**
 * This focuses an element
 * @param {HTMLElement} element The element for which to replace the link href for.
 * @returns {void} Nothing
 */
export default function autofocus(element) {
  let node = element.querySelector(".editor .ProseMirror, input[type='text'], textarea")

  if (!node) {
    return;
  }

  node.dispatchEvent(new CustomEvent("move-cursor-to-end", { bubbles: true }));

  if (typeof element.focus === "function") {
    node.focus();
  }

  let value = node.value;
  node.value = "";
  node.value = value;
}
