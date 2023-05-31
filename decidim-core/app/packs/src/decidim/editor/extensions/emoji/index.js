import { Extension } from "@tiptap/core";

import { EmojiButton } from "src/decidim/input_emoji";

const createEmojiButton = (editor) => {
  const { view: { dom } } = editor;
  return new EmojiButton(dom);
}

export default Extension.create({
  name: "emoji",

  onCreate({ editor }) {
    createEmojiButton(editor);
  }
});
