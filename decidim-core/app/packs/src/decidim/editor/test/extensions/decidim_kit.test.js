import { Editor } from "@tiptap/core";

import DecidimKit from "src/decidim/editor/extensions/decidim_kit";

import { createEditorContainer } from "src/decidim/editor/test/helpers";

describe("DecidimKit", () => {
  const createEditor = (config = {}) => {
    const editorElement = document.querySelector(".editor .editor-input");
    return new Editor({
      element: editorElement,
      content: "",
      extensions: [DecidimKit.configure(config)]
    });
  };
  const getCurrentExtensions = (editor) => {
    return editor.extensionManager.extensions.map((ext) => ext.name);
  };

  beforeEach(() => {
    document.body.innerHTML = "";
    createEditorContainer({});
  });

  describe("with default configuration", () => {
    it("adds the starter kit extensions", () => {
      const editor = createEditor();
      const extensions = getCurrentExtensions(editor);
      [
        "blockquote",
        "bulletList",
        "code",
        "doc",
        "dropCursor",
        "gapCursor",
        "hardBreak",
        "history",
        "horizontalRule",
        "italic",
        "listItem",
        "paragraph",
        "strike",
        "text"
      ].forEach((name) => expect(extensions).toContain(name));
    });

    it("adds the custom editing extensions", () => {
      const editor = createEditor();
      const extensions = getCurrentExtensions(editor);
      [
        "characterCount",
        "heading",
        "link",
        "bold",
        "dialog",
        "indent",
        "orderedList",
        "codeBlock",
        "underline"
      ].forEach((name) => expect(extensions).toContain(name));
    });

    it("does not add the configurable extensions", () => {
      const editor = createEditor();
      const extensions = getCurrentExtensions(editor);
      [
        "videoEmbed",
        "image",
        "hashtag",
        "mention",
        "emoji"
      ].forEach((name) => expect(extensions).not.toContain(name));
    });
  });

  const extensionSettings = {
    videoEmbed: true,
    image: { uploadDialogSelector: "#upload_dialog", uploadImagesPath: "/upload" },
    hashtag: true,
    mention: true,
    mentionResource: true,
    emoji: true
  };
  Object.keys(extensionSettings).forEach((extensionKey) => {
    const settings = extensionSettings[extensionKey];

    describe(`with ${extensionKey}`, () => {
      it("adds the extension", () => {
        const editor = createEditor({ [extensionKey]: settings });
        const extensions = getCurrentExtensions(editor);
        expect(extensions).toContain(extensionKey)
      });
    });
  });
});
