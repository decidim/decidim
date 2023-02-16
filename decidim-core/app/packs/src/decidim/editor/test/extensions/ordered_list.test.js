import { Editor } from "@tiptap/core";
import Document from "@tiptap/extension-document";
import Paragraph from "@tiptap/extension-paragraph";
import BulletList from "@tiptap/extension-bullet-list";
import ListItem from "@tiptap/extension-list-item";
import Text from "@tiptap/extension-text";

import { updateContent, pasteContent } from "../helpers";

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

const formattedList = `
  <ol>
    <li>
      <p>Item 1</p>
      <ol type="a" data-type="a">
        <li><p>Subitem 1.1</p></li>
        <li><p>Subitem 1.2</p></li>
      </ol>
    </li>
    <li>
      <p>Item 2</p>
      <ol type="A" data-type="A">
        <li><p>Subitem 2.1</p></li>
        <li><p>Subitem 2.2</p></li>
      </ol>
    </li>
    <li>
      <p>Item 3</p>
      <ol type="i" data-type="i">
        <li><p>Subitem 3.1</p></li>
        <li><p>Subitem 3.2</p></li>
      </ol>
    </li>
    <li>
      <p>Item 4</p>
      <ol type="I" data-type="I">
        <li><p>Subitem 4.1</p></li>
        <li><p>Subitem 4.2</p></li>
      </ol>
    </li>
  </ol>
`;

describe("OrderedList", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor()
    editorElement = editor.view.dom;
  });

  it("preserves the list types when manually updated content is processed", async () => {
    editorElement.focus();
    await updateContent(editorElement, formattedList);

    expect(editor.getHTML()).toMatchHtml(formattedList.replace(/\n( {2})*/g, ""));
  });

  // See: https://github.com/ueberdosis/tiptap/issues/3726
  it("preserves the list types when they are carried using inline styling", async () => {
    const listContent = `
      <b style="font-weight:normal;">
        <ol>
          <li style="list-style-type:decimal;">
            <p>Item 1</p>
          </li>
          <ol>
            <li style="list-style-type:lower-alpha;font-weight:400;"><p>Subitem 1.1</p></li>
            <li style="list-style-type:lower-alpha;font-weight:normal;"><p>Subitem 1.2</p></li>
          </ol>
          <li style="list-style-type:decimal;">
            <p>Item 2</p>
          </li>
          <ol>
            <li style="list-style-type:upper-alpha;font-weight:400;"><p>Subitem 2.1</p></li>
            <li style="list-style-type:upper-alpha;font-weight:normal;"><p>Subitem 2.2</p></li>
          </ol>
          <li style="list-style-type:decimal;">
            <p>Item 3</p>
          </li>
          <ol>
            <li style="list-style-type:lower-roman;font-weight:400;"><p>Subitem 3.1</p></li>
            <li style="list-style-type:lower-roman;font-weight:normal;"><p>Subitem 3.2</p></li>
          </ol>
          <li style="list-style-type:decimal;">
            <p>Item 4</p>
          </li>
          <ol>
            <li style="list-style-type:upper-roman;font-weight:400;"><p>Subitem 4.1</p></li>
            <li style="list-style-type:upper-roman;font-weight:normal;"><p>Subitem 4.2</p></li>
          </ol>
        </ol>
      </b>
    `;

    editorElement.focus();
    await updateContent(editorElement, listContent);

    expect(editor.getHTML()).toMatchHtml(formattedList.replace(/\n( {2})*/g, ""));
  });

  // See: https://github.com/ueberdosis/tiptap/issues/3751
  it("preserves the list types when they are carried using inline styling from Office 365", async () => {
    const listContent = `
      <div class="ListContainerWrapper">
        <ol style="list-style-type:decimal;">
          <li data-listid="1" data-aria-level="1"><p><span>Item 1</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:lower-alpha;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 1.1</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:lower-alpha;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:normal;">Subitem 1.2</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:decimal;">
          <li data-listid="1" data-aria-level="1"><p><span>Item 2</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:upper-alpha;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 2.1</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:upper-alpha;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:normal;">Subitem 2.2</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:decimal;">
          <li data-listid="1" data-aria-level="1"><p><span>Item 3</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:lower-roman;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 3.1</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:lower-roman;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:normal;">Subitem 3.2</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:decimal;">
          <li data-listid="1" data-aria-level="1"><p><span>Item 4</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:upper-roman;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 4.1</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:upper-roman;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:normal;">Subitem 4.2</span></p></li>
        </ol>
      </div>
    `;

    editorElement.focus();
    // await updateContent(editorElement, listContent);
    await pasteContent(editorElement, listContent);

    expect(editor.getHTML()).toMatchHtml(formattedList.replace(/\n( {2})*/g, ""));
  });

  it("allows changing the list type with ALT+SHIFT+DOWN", async () => {
    const listContent = "<ol><li><p>Item</p></li></ol>";

    editorElement.focus();
    await updateContent(editorElement, listContent);

    ["a", "A", "i", "I"].forEach((type) => {
      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowDown", shiftKey: true, altKey: true }))
      expect(editor.getHTML()).toMatchHtml(`<ol type="${type}" data-type="${type}"><li><p>Item</p></li></ol>`);
    });

    editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowDown", shiftKey: true, altKey: true }))
    expect(editor.getHTML()).toMatchHtml("<ol><li><p>Item</p></li></ol>");
  });

  it("allows changing the list type with ALT+SHIFT+UP", async () => {
    const listContent = "<ol><li><p>Item</p></li></ol>";

    editorElement.focus();
    await updateContent(editorElement, listContent);

    ["I", "i", "A", "a"].forEach((type) => {
      editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowUp", shiftKey: true, altKey: true }))
      expect(editor.getHTML()).toMatchHtml(`<ol type="${type}" data-type="${type}"><li><p>Item</p></li></ol>`);
    });

    editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowUp", shiftKey: true, altKey: true }))
    expect(editor.getHTML()).toMatchHtml("<ol><li><p>Item</p></li></ol>");
  });
});
