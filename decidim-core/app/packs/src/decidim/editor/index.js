import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
import Underline from "@tiptap/extension-underline";

import CodeBlock from "src/decidim/editor/extensions/code_block";
import Image from "src/decidim/editor/extensions/image";
import Indent from "src/decidim/editor/extensions/indent";
import Link from "src/decidim/editor/extensions/link";
import Dialog from "src/decidim/editor/extensions/dialog";
import VideoEmbed from "src/decidim/editor/extensions/video_embed";

import { getDictionary } from "src/decidim/i18n";
import createEditorToolbar from "src/decidim/editor/toolbar";
import UploadModal from "src/decidim/editor/upload_modal";

/**
 * Creates a new rich text editor instance.
 *
 * TODO:
 * - Replace legacy classes in tests/markup .ql-editor
 *
 * @param {HTMLElement} container The element that contains the editor.
 * @return {Editor} The rich text editor instance.
 */
export default function createEditor(container) {
  const input = container.parentElement.querySelector("input[type=hidden]");

  const editorContainer = document.createElement("div");
  editorContainer.classList.add("editor-input");
  container.appendChild(editorContainer);

  let editor = null;
  const i18nUpload = getDictionary("editor.upload");
  const options = JSON.parse(container.dataset.options);
  const { uploadImagesPath, uploadModalSelector, contentTypes } = options;
  const uploadModal = new UploadModal(
    document.querySelector(uploadModalSelector),
    {
      i18n: i18nUpload,
      onOpen: () => editor.commands.toggleDialog(true),
      onClose: () => editor.chain().toggleDialog(false).focus(null, { scrollIntoView: false }).run()
    }
  );

  editor = new Editor({
    element: editorContainer,
    extensions: [
      StarterKit.configure({
        heading: { levels: [2, 3, 4, 5, 6] },
        codeBlock: false
      }),
      Dialog,
      Indent,
      CodeBlock,
      Link.configure({ openOnClick: false }),
      Underline,
      VideoEmbed,
      Image.configure({ uploadModal, uploadImagesPath, contentTypes: contentTypes.image })
    ],
    content: input.value,
    editable: !input.disabled
  });

  const toolbar = createEditorToolbar(editor);
  container.insertBefore(toolbar, editorContainer);

  editor.on("update", () => (input.value = editor.getHTML()));

  return editor;
}
