import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
import Underline from "@tiptap/extension-underline";

import { getDictionary } from "src/decidim/i18n";

import CodeBlock from "src/decidim/editor/extensions/code_block";
import Image from "src/decidim/editor/extensions/image";
import Indent from "src/decidim/editor/extensions/indent";
import Link from "src/decidim/editor/extensions/link";
import VideoEmbed from "src/decidim/editor/extensions/video_embed";

import createEditorToolbar from "src/decidim/editor/toolbar";
import UploadModal from "src/decidim/editor/upload_modal";

/**
 * Creates a new rich text editor instance.
 *
 * TODO:
 * - Integrate with redesigned layout
 * - Confirm configuration is according to the legacy Quill configs (e.g.
 *   pasting options, pasting content with styling, etc.)
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

  const options = JSON.parse(container.dataset.options);
  const { uploadImagesPath, uploadModalSelector, contentTypes } = options;
  const uploadModal = new UploadModal(document.querySelector(uploadModalSelector));

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
      Image.configure({ uploadModal, uploadImagesPath, contentTypes: contentTypes.image })
    ],
    content: input.value
  });

  const toolbar = createEditorToolbar(editor, { i18n: getDictionary("editor.toolbar") });
  container.insertBefore(toolbar, editorContainer);

  editor.on("update", () => {
    input.value = editor.getHTML();
  });

  return editor;
}
