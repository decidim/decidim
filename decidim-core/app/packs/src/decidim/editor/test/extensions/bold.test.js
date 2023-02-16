import { Editor } from "@tiptap/core";
import Document from "@tiptap/extension-document";
import Paragraph from "@tiptap/extension-paragraph";
import BulletList from "@tiptap/extension-bullet-list";
import OrderedList from "@tiptap/extension-ordered-list";
import ListItem from "@tiptap/extension-list-item";
import Text from "@tiptap/extension-text";

import Bold from "../../extensions/bold";
// import OrderedList from "../../extensions/ordered_list";

import { updateContent } from "../helpers";

const createBasicEditor = () => {
  const element = document.createElement("div");
  element.classList.add("editor-input");
  document.body.append(element);

  return new Editor({
    element,
    content: "",
    extensions: [Document, Paragraph, Text, Bold, BulletList, OrderedList, ListItem]
  });
};

describe("Bold", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor();
    editorElement = editor.view.dom;
  });

  // See: https://github.com/ueberdosis/tiptap/issues/3735
  describe("with a surrounding `<b>` element containing a list", () => {
    it("renders correctly", async () => {
      await updateContent(editorElement, `
        <b style="font-weight:normal;">
          <ol>
            <li><p><span style="font-weight:700;">Item 1</span></p></li>
            <ol>
              <li><p><span style="font-weight:400;">Subitem 1.1</span></p></li>
            </ol>
            <li><p><span style="font-weight:bold;">Item 2</span></p></li>
            <ol>
              <li><p><span style="font-weight:normal;">Subitem 2.1</span></p></li>
            </ol>
          </ol>
        </b>
      `);

      expect(editor.getHTML()).toMatchHtml(`
        <ol>
          <li>
            <p><strong>Item 1</strong></p>
            <ol><li><p>Subitem 1.1</p></li></ol>
          </li>
          <li>
            <p><strong>Item 2</strong></p>
            <ol><li><p>Subitem 2.1</p></li></ol>
          </li>
        </ol>
      `);
    });
  });
});
