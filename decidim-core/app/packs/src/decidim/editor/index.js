import { Editor } from "@tiptap/core";

import DecidimKit from "src/decidim/editor/extensions/decidim_kit";

import createEditorToolbar from "src/decidim/editor/toolbar";
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

  /**
   * Toolbar features can be one of:
   *
   * - basic = only basic controls without headings
   * - content = basic + headings
   * - full = basic + headings + image + video
   */
  const features = container.dataset?.toolbar || "basic";
  const options = JSON.parse(container.dataset.options);
  const { context, contentTypes } = options;

  const decidimOptions = {};

  if (context !== "participant") {
    decidimOptions.link = { allowTargetControl: true };
  }

  if (input.hasAttribute("maxlength")) {
    decidimOptions.characterCount = { limit: parseInt(input.getAttribute("maxlength"), 10) };
  }

  if (features === "basic") {
    decidimOptions.heading = false;
  }

  if (features === "full") {
    decidimOptions.videoEmbed = true;

    const { uploadImagesPath, uploadDialogSelector } = options;
    decidimOptions.image = {
      uploadDialogSelector,
      contentTypes: contentTypes.image,
      uploadImagesPath
    };
  }

  if (container.classList.contains("js-mentions")) {
    decidimOptions.mention = true;
  }
  if (container.classList.contains("js-emojis")) {
    decidimOptions.emoji = true;
  }
  if (container.classList.contains("js-resource-mentions")) {
    decidimOptions.mentionResource = true;
  }

  const editor = new Editor({
    element: editorContainer,
    editorProps: { attributes: editorAttributes },
    content: input.value,
    editable: !input.disabled,
    extensions: [DecidimKit.configure(decidimOptions)]
  });

  const toolbar = createEditorToolbar(editor);
  container.insertBefore(toolbar, editorContainer);

  editor.on("update", () => (input.value = editor.getHTML()));

  return editor;
}
