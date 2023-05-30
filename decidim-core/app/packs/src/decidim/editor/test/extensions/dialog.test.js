import { createBasicEditor } from "../helpers";

import Dialog from "../../extensions/dialog";

describe("Dialog", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor({ extensions: [Dialog] })
    editorElement = editor.view.dom;
  });

  it("does not add extra class by default", () => {
    expect(editorElement.classList.contains("dialog-open")).toBe(false);
  });

  it("adds the correct class to the element when toggled", async () => {
    editor.commands.toggleDialog(true);
    expect(editorElement.classList.contains("dialog-open")).toBe(true);
  });

  it("removes the correct class from the element when disabled", async () => {
    editor.commands.toggleDialog(true);
    expect(editorElement.classList.contains("dialog-open")).toBe(true);

    editor.commands.toggleDialog(false);
    expect(editorElement.classList.contains("dialog-open")).toBe(false);
  });
});
