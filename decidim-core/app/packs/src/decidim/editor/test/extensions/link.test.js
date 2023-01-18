import { createBasicEditor, updateContent, selectRange, sleep } from "../helpers";

import Dialog from "../../extensions/dialog";
import Link from "../../extensions/link";

describe("Link", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor({ extensions: [Dialog, Link] })
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
      '<p>Hello, <a target="_blank" rel="noopener noreferrer nofollow" href="https://decidim.org">world</a>!</p>'
    );
  });

  it("allows editing the link through the dialog", async () => {
    editorElement.focus();
    await updateContent(editorElement,
      '<p>Hello, <a target="_blank" rel="noopener noreferrer nofollow" href="https://decidim.org">world</a>!</p>'
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
      '<p>Hello, <a rel="noopener noreferrer nofollow" href="https://docs.decidim.org">world</a>!</p>'
    );
  });
});
