import { Editor } from "@tiptap/core";
import Document from "@tiptap/extension-document";
import Paragraph from "@tiptap/extension-paragraph";
import BulletList from "@tiptap/extension-bullet-list";
import OrderedList from "@tiptap/extension-ordered-list";
import ListItem from "@tiptap/extension-list-item";
import Text from "@tiptap/extension-text";

import { updateContent } from "src/decidim/editor/test/helpers";

import Heading from "@tiptap/extension-heading";

const createBasicEditor = () => {
  const element = document.createElement("div");
  element.classList.add("editor-input");
  document.body.append(element);

  return new Editor({
    element,
    content: "",
    extensions: [Document, Heading.configure({ levels: [2, 3, 4, 5, 6] }), Paragraph, Text, BulletList, OrderedList, ListItem]
  });
};

describe("Heading", () => {
  let editor = null;
  let editorElement = null;

  const expectHeadingWithLevel = async (level) => {
    editorElement.focus();
    await updateContent(editorElement, `${"#".repeat(level)} `);

    const tag = `h${level}`;
    expect(editor.getHTML()).toMatchHtml(`<${tag}></${tag}>`);
  };

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor()
    editorElement = editor.view.dom;
  });

  it("allows creating a 2nd level heading with a markdown shortcut", async () => await expectHeadingWithLevel(2));
  it("allows creating a 3rd level heading with a markdown shortcut", async () => await expectHeadingWithLevel(3));
  it("allows creating a 4th level heading with a markdown shortcut", async () => await expectHeadingWithLevel(4));
  it("allows creating a 5th level heading with a markdown shortcut", async () => await expectHeadingWithLevel(5));
  it("allows creating a 6th level heading with a markdown shortcut", async () => await expectHeadingWithLevel(6));

  it("does not allow creating a first level heading with a markdown shortcut", async () => {
    editorElement.focus();
    await updateContent(editorElement, "# ");

    expect(editor.getHTML()).toMatchHtml("<h2></h2>");
  });
});
