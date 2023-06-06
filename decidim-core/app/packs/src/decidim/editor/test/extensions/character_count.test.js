import { createBasicEditor, updateContent } from "../helpers";

import CharacterCount from "../../extensions/character_count";

describe("CharacterCount", () => {
  let editor = null;
  let editorElement = null;

  const setupEditor = (extension) => {
    editor = createBasicEditor({ extensions: [extension] })
    editorElement = editor.view.dom;
  };

  beforeEach(() => {
    document.body.innerHTML = "";
  });

  describe("with no options", () => {
    beforeEach(() => setupEditor(CharacterCount));

    it("counts the characters", async () => {
      editorElement.focus();
      await updateContent(editorElement, "Hello, world!");

      expect(editor.storage.characterCount.characters()).toBe(13);
    });
  });

  describe("with a defined character limit", () => {
    beforeEach(() => setupEditor(CharacterCount.configure({ limit: 13 })));

    // See: https://github.com/ueberdosis/tiptap/issues/3721
    it("does not allow new paragraphs after reaching the characters limit", async () => {
      editorElement.focus();
      await updateContent(editorElement, "Hello, world!");

      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Enter" }));
      expect(editor.getHTML()).toEqual("<p>Hello, world!</p>");
    });
  });
});
