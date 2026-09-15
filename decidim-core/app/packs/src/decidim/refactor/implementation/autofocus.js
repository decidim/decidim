/**
 * This focuses an element
 * @param {HTMLElement} element The container element to search for a focusable input or editor.
 * @returns {void} Nothing
 */
export default function autofocus(element) {
  let node = element.querySelector(".editor .ProseMirror, input[type='text'], textarea")

  if (!node) {
    return;
  }

  node.dispatchEvent(new CustomEvent("move-cursor-to-end", { bubbles: true }));

  if (typeof node.focus === "function") {
    node.focus();
  }

  let value = node.value;
  node.value = "";
  node.value = value;
}
