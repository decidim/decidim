import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
import Underline from "@tiptap/extension-underline";
import CharacterCount from "@tiptap/extension-character-count";

import CodeBlock from "src/decidim/editor/extensions/code_block";
import Dialog from "src/decidim/editor/extensions/dialog";
import Hashtag from "src/decidim/editor/extensions/hashtag";
import Image from "src/decidim/editor/extensions/image";
import Indent from "src/decidim/editor/extensions/indent";
import Link from "src/decidim/editor/extensions/link";
import Mention from "src/decidim/editor/extensions/mention";
import VideoEmbed from "src/decidim/editor/extensions/video_embed";

import { getDictionary } from "src/decidim/i18n";
import createEditorToolbar from "src/decidim/editor/toolbar";
import UploadDialog from "src/decidim/editor/common/upload_dialog";

/**
 * Creates a new rich text editor instance.
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
  const { uploadImagesPath, uploadDialogSelector, contentTypes } = options;
  const uploadDialog = new UploadDialog(
    document.querySelector(uploadDialogSelector),
    {
      i18n: i18nUpload,
      onOpen: () => editor.commands.toggleDialog(true),
      onClose: () => editor.chain().toggleDialog(false).focus(null, { scrollIntoView: false }).run()
    }
  );

  const characterCountOptions = {};
  if (input.hasAttribute("maxlength")) {
    characterCountOptions.limit = parseInt(input.getAttribute("maxlength"), 10);
  }

  const extensions = [
    StarterKit.configure({
      heading: { levels: [2, 3, 4, 5, 6] },
      codeBlock: false
    }),
    CharacterCount.configure(characterCountOptions),
    Dialog,
    Indent,
    CodeBlock,
    Link.configure({ openOnClick: false }),
    Underline,
    VideoEmbed,
    Image.configure({ uploadDialog, uploadImagesPath, contentTypes: contentTypes.image })
  ];

  if (editorContainer.classList.contains("js-hashtags")) {
    extensions.push(Hashtag);
  }
  if (editorContainer.classList.contains("js-mentions")) {
    extensions.push(Mention);
  }

  editor = new Editor({
    element: editorContainer,
    content: input.value,
    editable: !input.disabled,
    extensions
  });

  const toolbar = createEditorToolbar(editor);
  container.insertBefore(toolbar, editorContainer);

  editor.on("update", () => (input.value = editor.getHTML()));

  return editor;
}
