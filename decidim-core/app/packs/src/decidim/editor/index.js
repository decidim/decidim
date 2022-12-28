import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
import Underline from "@tiptap/extension-underline";

import CodeBlock from "src/decidim/editor/extensions/code_block";
import Image from "src/decidim/editor/extensions/image";
import Indent from "src/decidim/editor/extensions/indent";
import Link from "src/decidim/editor/extensions/link";
import VideoEmbed from "src/decidim/editor/extensions/video_embed";

import createEditorToolbar from "src/decidim/editor/toolbar";

/**
 * Creates a new rich text editor instance.
 *
 * Missing features:
 * - Highlight the currently active control from the toolbar
 * - Uploading an image through the image modal
 * - Integrate with redesigned layout
 * - Confirm configuration is according to the legacy Quill configs (e.g.
 *   pasting options, pasting content with styling, etc.)
 * - Translations
 * - Replace legacy classes in tests/markup .ql-editor, .ql-reset-decidim,
 *   .ql-video, .ql-toolbar, etc.
 *
 * @param {HTMLElement} container The element that contains the editor.
 * @return {Editor} The rich text editor instance.
 */
export default function createEditor(container) {
  const input = container.parentElement.querySelector("input[type=hidden]");

  const editorContainer = document.createElement("div");
  editorContainer.classList.add("editor-input");
  container.appendChild(editorContainer);

  const { uploadImagesPath } = container.dataset;

  const editor = new Editor({
    element: editorContainer,
    extensions: [
      StarterKit.configure({
        heading: { levels: [2, 3, 4, 5, 6] },
        codeBlock: false
      }),
      Indent,
      CodeBlock,
      Link.configure({ openOnClick: false }),
      Underline,
      VideoEmbed,
      Image.configure({ uploadImagesPath })
    ],
    content: input.value
  });

  const toolbar = createEditorToolbar(editor);
  container.insertBefore(toolbar, editorContainer);

  editor.on("update", () => {
    input.value = editor.getHTML();
  });

  return editor;
}
