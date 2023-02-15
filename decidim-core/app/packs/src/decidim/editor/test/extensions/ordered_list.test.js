import { Editor } from "@tiptap/core";
import { Document } from "@tiptap/extension-document";
import { Paragraph } from "@tiptap/extension-paragraph";
import { BulletList } from "@tiptap/extension-bullet-list";
import { ListItem } from "@tiptap/extension-list-item";
import { Text } from "@tiptap/extension-text";

import { updateContent } from "../helpers";

import OrderedList from "../../extensions/ordered_list";

const createBasicEditor = () => {
  const element = document.createElement("div");
  element.classList.add("editor-input");
  document.body.append(element);

  return new Editor({
    element,
    content: "",
    extensions: [Document, Paragraph, Text, BulletList, OrderedList, ListItem]
  });
};

describe("OrderedList", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor()
    editorElement = editor.view.dom;
  });

  it("preserves the list types when manually updated content is processed", async () => {
    const listContent = `
      <ol>
        <li>
          <p>Item 1</p>
          <ol type="a">
            <li><p>Subitem 1.1</p></li>
            <li><p>Subitem 1.2</p></li>
          </ol>
        </li>
        <li>
          <p>Item 2</p>
          <ol type="A">
            <li><p>Subitem 2.1</p></li>
            <li><p>Subitem 2.2</p></li>
          </ol>
        </li>
        <li>
          <p>Item 3</p>
          <ol type="i">
            <li><p>Subitem 3.1</p></li>
            <li><p>Subitem 3.2</p></li>
          </ol>
        </li>
        <li>
          <p>Item 4</p>
          <ol type="I">
            <li><p>Subitem 4.1</p></li>
            <li><p>Subitem 4.2</p></li>
          </ol>
        </li>
      </ol>
    `;

    editorElement.focus();
    await updateContent(editorElement, listContent);

    expect(editor.getHTML()).toMatchHtml(listContent.replace(/\n( {2})+/g, ""));
  });
});
