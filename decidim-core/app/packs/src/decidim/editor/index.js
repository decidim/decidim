import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
import CodeBlock from "@tiptap/extension-code-block";
import Underline from "@tiptap/extension-underline";

import CharacterCount from "src/decidim/editor/extensions/character_count";
import Dialog from "src/decidim/editor/extensions/dialog";
import Hashtag from "src/decidim/editor/extensions/hashtag";
import Heading from "src/decidim/editor/extensions/heading";
import OrderedList from "src/decidim/editor/extensions/ordered_list";
import Image from "src/decidim/editor/extensions/image";
import Indent from "src/decidim/editor/extensions/indent";
import Link from "src/decidim/editor/extensions/link";
import Mention from "src/decidim/editor/extensions/mention";
import VideoEmbed from "src/decidim/editor/extensions/video_embed";
import Emoji from "src/decidim/editor/extensions/emoji";

import { getDictionary } from "src/decidim/i18n";
import createEditorToolbar from "src/decidim/editor/toolbar";
import UploadDialog from "src/decidim/editor/common/upload_dialog";
import { uniqueId } from "src/decidim/editor/common/helpers";

/**
 * Creates a new rich text editor instance.
 *
 * @param {HTMLElement} container The element that contains the editor.
 * @return {Editor} The rich text editor instance.
 */
export default function createEditor(container) {
  const input = container.parentElement.querySelector("input[type=hidden]");
  const label = container.parentElement.querySelector("label");
  const editorContainer = container.querySelector(".editor-input");

  const editorAttributes = { role: "textbox", "aria-multiline": true };
  if (label) {
    const labelId = uniqueId("editorlabel");
    label.setAttribute("id", labelId);
    editorAttributes["aria-labelledby"] = labelId;
  }

  let editor = null;
  const i18nUpload = getDictionary("editor.upload");
  const features = container.dataset?.toolbar || "basic";
  const options = JSON.parse(container.dataset.options);
  const { context, uploadImagesPath, uploadDialogSelector, contentTypes } = options;
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

  const linkOptions = { openOnClick: false };
  if (context !== "participant") {
    linkOptions.allowTargetControl = true;
  }

  const extensions = [
    StarterKit.configure({
      heading: false,
      orderedList: false,
      codeBlock: false
    }),
    Heading.configure({ levels: [2, 3, 4, 5, 6] }),
    CharacterCount.configure(characterCountOptions),
    Dialog,
    Indent,
    OrderedList,
    CodeBlock,
    Link.configure(linkOptions),
    Underline
  ];
  if (features === "full") {
    extensions.push(...[
      VideoEmbed,
      Image.configure({ uploadDialog, uploadImagesPath, contentTypes: contentTypes.image })
    ]);
  }

  if (container.classList.contains("js-hashtags")) {
    extensions.push(Hashtag);
  }
  if (container.classList.contains("js-mentions")) {
    extensions.push(Mention);
  }
  if (container.classList.contains("js-emojis")) {
    extensions.push(Emoji);
  }

  editor = new Editor({
    element: editorContainer,
    editorProps: { attributes: editorAttributes },
    content: input.value,
    editable: !input.disabled,
    extensions
  });

  const toolbar = createEditorToolbar(editor);
  container.insertBefore(toolbar, editorContainer);

  editor.on("update", () => (input.value = editor.getHTML()));

  return editor;
}
