/**
 * This focuses an element
 * @param {HTMLElement} element The container element to search for a focusable input or editor.
 * @returns {void} Nothing
 */
export default function autofocus(element) {
  if (!element) {
    return;
  }

  let node = element.querySelector(".editor .ProseMirror, input[type='text'], textarea")

  if (!node) {
    // The editor is loaded lazily, so the ProseMirror element may not exist yet
    // when a language tab is revealed. Initialize it and retry the focus once
    // the editor is ready.
    const editor = element.querySelector(".editor .editor-container:not([data-editor-initialized='true'])");

    if (editor) {
      editor.addEventListener("editor:initialized", () => autofocus(element), { once: true });
      editor.dispatchEvent(new CustomEvent("editor:reveal", { bubbles: true }));
    }

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
