import { Editor } from "@tiptap/core";

import { createEditorContainer, updateContent } from "../helpers";

describe("createEditor", () => {
  const ctx = {
    editorContainer: null
  };

  beforeEach(() => {
    document.body.innerHTML = "";
  });
  afterEach(() => (ctx.editorContainer = null));

  it("creates the editor toolbar", () => {
    const toolbar = createEditorContainer().querySelector(".editor-toolbar");
    expect(toolbar).toBeInstanceOf(HTMLElement);
  });

  it("creates the contenteditable element inside the editor input", () => {
    const editorInput = createEditorContainer().querySelector(".editor-input");
    expect(editorInput.querySelector(".ProseMirror[contenteditable='true']")).toBeInstanceOf(HTMLElement);
  });

  it("exposes the editor through the contenteditable element", () => {
    const prosemirror = createEditorContainer().querySelector(".editor-input .ProseMirror");
    expect(prosemirror.editor).toBeInstanceOf(Editor);
  });

  it("updates the input content when the content in the editor changes", async () => {
    const prosemirror = createEditorContainer().querySelector(".editor-input .ProseMirror");
    const input = document.querySelector(".editor > input");

    await updateContent(prosemirror, "Hello, world!")

    expect(input.value).toEqual("<p>Hello, world!</p>")
  });
});
