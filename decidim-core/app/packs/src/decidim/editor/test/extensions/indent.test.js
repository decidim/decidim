import { createBasicEditor, updateContent, selectRange } from "../helpers";

import Indent from "../../extensions/indent";

describe("Indent", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor({ extensions: [Indent] })
    editorElement = editor.view.dom;
  });

  describe("with paragraph", () => {
    it("allows indenting the content", async () => {
      await updateContent(editorElement, "Hello, world!");

      editor.commands.indent();
      expect(editor.getHTML()).toEqual('<p class="editor-indent-1">Hello, world!</p>');

      editor.commands.indent();
      expect(editor.getHTML()).toEqual('<p class="editor-indent-2">Hello, world!</p>');
    });

    it("does not allow indenting above the maximum indentation level", async () => {
      await updateContent(editorElement, "Hello, world!");

      for (let idx = 0; idx < 20; idx += 1) {
        editor.commands.indent();
      }

      expect(editor.getHTML()).toEqual('<p class="editor-indent-10">Hello, world!</p>');
    });

    it("allows outdenting already indented content", async () => {
      await updateContent(editorElement, '<p class="editor-indent-2">Hello, world!</p>');

      editor.commands.outdent();
      expect(editor.getHTML()).toEqual('<p class="editor-indent-1">Hello, world!</p>');

      editor.commands.outdent();
      expect(editor.getHTML()).toEqual("<p>Hello, world!</p>");
    });

    it("does not outdent content that is not indented", async () => {
      await updateContent(editorElement, "Hello, world!");

      editor.commands.outdent();
      expect(editor.getHTML()).toEqual("<p>Hello, world!</p>");
    });
  });

  describe("with heading", () => {
    it("allows indenting the content", async () => {
      await updateContent(editorElement, "<h2>Hello, world!</h2>");

      editor.commands.indent();
      expect(editor.getHTML()).toEqual('<h2 class="editor-indent-1">Hello, world!</h2>');
    });

    it("allows outdenting the content", async () => {
      await updateContent(editorElement, '<h2 class="editor-indent-2">Hello, world!</h2>');

      editor.commands.outdent();
      expect(editor.getHTML()).toEqual('<h2 class="editor-indent-1">Hello, world!</h2>');

      editor.commands.outdent();
      expect(editor.getHTML()).toEqual("<h2>Hello, world!</h2>");
    });
  });

  describe("with list", () => {
    it("allows indenting the list", async () => {
      await updateContent(editorElement, "<ul><li><p>Item 1</p></li><li><p>Item 2</p></li></ul>");

      editorElement.focus();
      editor.commands.indent();
      expect(editor.getHTML()).toEqual("<ul><li><p>Item 1</p><ul><li><p>Item 2</p></li></ul></li></ul>");
    });

    it("allows outdenting the list", async () => {
      await updateContent(editorElement, "<ul><li><p>Item 1</p><ul><li><p>Item 2</p></li></ul></li></ul>");

      editorElement.focus();
      editor.commands.outdent();
      expect(editor.getHTML()).toEqual("<ul><li><p>Item 1</p></li><li><p>Item 2</p></li></ul>");
    });

    it("does not outdent the list at the top level", async () => {
      await updateContent(editorElement, "<ul><li><p>Item 1</p></li></ul>");

      editorElement.focus();
      editor.commands.outdent();
      expect(editor.getHTML()).toEqual("<ul><li><p>Item 1</p></li></ul>");
    });
  });

  describe("with keyboard", () => {
    it("allows indenting the content with Tab", async () => {
      await updateContent(editorElement, "Hello, world!");

      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Tab" }));

      expect(editor.getHTML()).toEqual('<p class="editor-indent-1">Hello, world!</p>');
    });

    it("allows indenting the content with Mod+]", async () => {
      await updateContent(editorElement, "Hello, world!");

      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "]", ctrlKey: true }));

      expect(editor.getHTML()).toEqual('<p class="editor-indent-1">Hello, world!</p>');
    });

    it("allows outdenting the content using Shift+Tab", async () => {
      await updateContent(editorElement, '<p class="editor-indent-1">Hello, world!</p>');

      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Tab", shiftKey: true }));

      expect(editor.getHTML()).toEqual("<p>Hello, world!</p>");
    });

    it("allows outdenting the content using Mod+[", async () => {
      await updateContent(editorElement, '<p class="editor-indent-1">Hello, world!</p>');

      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "[", ctrlKey: true }));

      expect(editor.getHTML()).toEqual("<p>Hello, world!</p>");
    });

    it("outdents the content at the beginning of the line using a backspace", async () => {
      await updateContent(editorElement, '<p class="editor-indent-2">Hello, world!</p>');

      await selectRange(editorElement, editorElement.querySelector("p").firstChild, { start: 0 });
      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Backspace" }));
      expect(editor.getHTML()).toEqual('<p class="editor-indent-1">Hello, world!</p>');

      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Backspace" }));
      expect(editor.getHTML()).toEqual("<p>Hello, world!</p>");
    });

    it("does not oudent the content if the selection is not at the beginning of the line", async () => {
      await updateContent(editorElement, '<p class="editor-indent-2">Hello, world!</p>');

      editorElement.focus();
      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Backspace", bubbles: true }));
      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Backspace", bubbles: true }));

      expect(editor.getHTML()).toEqual('<p class="editor-indent-2">Hello, world!</p>');
    });
  });
});
