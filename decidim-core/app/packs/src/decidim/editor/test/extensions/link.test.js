import { createBasicEditor, updateContent, selectRange, sleep } from "../helpers";

import Dialog from "../../extensions/dialog";
import Link from "../../extensions/link";

describe("Link", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor({ extensions: [Dialog, Link.configure({ allowTargetControl: true })] })
    editorElement = editor.view.dom;

    // Append a dummy data-dialog element to the DOM so that the document is
    // recognized as "redesigned" by the input dialog.
    const dummy = document.createElement("div");
    dummy.dataset.dialog = "";
    document.body.append(dummy);
  });

  it("allows setting the link through the dialog", async () => {
    editorElement.focus();
    await updateContent(editorElement, "Hello, world!");

    // Select the word "world" from the original text for the link
    await selectRange(editorElement, editorElement.querySelector("p").firstChild, { start: 7, end: 12 });

    editor.commands.linkDialog();
    expect(editorElement.classList.contains("dialog-open")).toBe(true);

    const dialog = document.querySelector("[data-dialog][aria-hidden='false']");
    dialog.querySelector("[data-input='href'] input").value = "https://decidim.org";
    dialog.querySelector("[data-input='target'] select").value = "_blank";
    dialog.querySelector("[data-dialog-actions] button[data-action='save']").click();
    await sleep(50);

    expect(editor.getHTML()).toEqual(
      '<p>Hello, <a target="_blank" href="https://decidim.org">world</a>!</p>'
    );
  });

  it("allows editing the link through the dialog", async () => {
    editorElement.focus();
    await updateContent(editorElement,
      '<p>Hello, <a target="_blank" href="https://decidim.org">world</a>!</p>'
    );

    // Set the editor cursor inside the link
    await selectRange(editorElement, editorElement.querySelector("p a").firstChild, { start: 3, end: 3 });

    editor.commands.linkDialog();
    expect(editorElement.classList.contains("dialog-open")).toBe(true);

    const dialog = document.querySelector("[data-dialog][aria-hidden='false']");
    dialog.querySelector("[data-input='href'] input").value = "https://docs.decidim.org";
    dialog.querySelector("[data-input='target'] select").value = "";
    dialog.querySelector("[data-dialog-actions] button[data-action='save']").click();
    await sleep(50);

    expect(editor.getHTML()).toEqual(
      '<p>Hello, <a href="https://docs.decidim.org">world</a>!</p>'
    );
  });

  describe("bubble menu", () => {
    let bubbleMenu = null;

    beforeEach(async () => {
      editorElement.focus();
      await updateContent(editorElement,
        '<p>Hello, <a target="_blank" href="https://decidim.org">world</a>!</p>'
      );

      // Set the editor cursor inside the link
      await selectRange(editorElement, editorElement.querySelector("p a").firstChild, { start: 3, end: 3 });

      bubbleMenu = editorElement.parentNode.querySelector("[data-bubble-menu] [data-linkbubble]");
    });

    it("shows the bubble menu when the link element has the cursor", () => {
      expect(bubbleMenu).toBeInstanceOf(HTMLElement);
      expect(bubbleMenu.parentNode.style.visibility).toEqual("visible");
      expect(bubbleMenu.textContent.replace(/^\s+/gm, "").trim()).toEqual("URL:\nhttps://decidim.org\nEdit\nRemove");
    });

    it("allows controlling the link through the bubble menu controls", async () => {
      bubbleMenu.querySelector("[data-action='edit']").click();
      expect(editorElement.classList.contains("dialog-open")).toBe(true);

      const dialog = document.querySelector("[data-dialog][aria-hidden='false']");
      expect(dialog).toBeInstanceOf(HTMLElement);

      dialog.querySelector("[data-dialog-actions] button[data-action='cancel']").click();
      await sleep(50);

      bubbleMenu = editorElement.parentNode.querySelector("[data-bubble-menu] [data-linkbubble]");
      bubbleMenu.querySelector("[data-action='remove']").click();
      expect(editor.getHTML()).toEqual("<p>Hello, world!</p>");
    });
  });
});
