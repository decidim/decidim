import { Extension } from "@tiptap/core";

const createEmojiButton = (editor) => {
  const { view: { dom } } = editor;

  return dom.setAttribute("data-controller", "emoji");
}

export default Extension.create({
  name: "emoji",

  onCreate({ editor }) {
    createEmojiButton(editor);
  }
});
