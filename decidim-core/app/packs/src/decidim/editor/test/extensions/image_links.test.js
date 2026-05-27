/* global jest, global */

import { createBasicEditor, updateContent, sleep } from "src/decidim/editor/test/helpers";

import Dialog from "src/decidim/editor/extensions/dialog";
import Image from "src/decidim/editor/extensions/image";
import uploadTemplates from "src/decidim/editor/test/fixtures/upload_templates";

class DummyDialog {
  constructor(element) { this.element = element; }

  open() { this.element.dataset.dialogOpen = true; }

  close() { this.element.dataset.dialogOpen = null; }
}

// Not implemented in Jest
global.Touch = class Touch {
  constructor(options) {
    this.pageX = options.pageX;
    this.pageY = options.pageY;
  }
}

describe("Image (links)", () => {
  let editor = null;
  let editorElement = null;
  let uploadDialogElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    const dialogWrapper = document.createElement("div");
    dialogWrapper.innerHTML = uploadTemplates.redesign;
    uploadDialogElement = dialogWrapper.firstElementChild;
    uploadDialogElement.dataset.dialog = "testDialog";
    uploadDialogElement.dialog = new DummyDialog(uploadDialogElement);
    window.Decidim.currentDialogs = { testDialog: uploadDialogElement.dialog };
    document.body.append(uploadDialogElement);

    editor = createBasicEditor({
      extensions: [Dialog, Image.configure({ uploadDialogSelector: "#upload_dialog", uploadImagesPath: "/editor_images", contentTypes: ["image/png"] })]
    });
    editorElement = editor.view.dom;

    const csrf = document.createElement("meta");
    csrf.setAttribute("name", "csrf-token");
    csrf.setAttribute("content", "abcdef0123456789");
    document.head.append(csrf);

    global.fetch = jest.fn(() => Promise.resolve({ ok: true, json: () => Promise.resolve({ url: "/path/to/image.jpg" }) }));
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("allows setting an image with href and target attributes", async () => {
    editorElement.focus();
    editor.commands.setImage({ src: "/path/to/image.jpg", alt: "Test image", href: "https://example.com", target: "_blank" });
    await sleep(0);

    expect(editor.getHTML()).toMatchHtml(`
      <a href="https://example.com" target="_blank" rel="noopener noreferrer">
        <div class="editor-content-image" data-image="">
          <img src="/path/to/image.jpg" alt="Test image">
        </div>
      </a>
    `);
  });

  it("allows setting an image with href but no target", async () => {
    editorElement.focus();
    editor.commands.setImage({ src: "/path/to/image.jpg", alt: "Test image", href: "https://example.com" });
    await sleep(0);

    expect(editor.getHTML()).toMatchHtml(`
      <a href="https://example.com">
        <div class="editor-content-image" data-image="">
          <img src="/path/to/image.jpg" alt="Test image">
        </div>
      </a>
    `);
  });

  it("parses existing HTML with linked images", async () => {
    editorElement.focus();
    await updateContent(editorElement,
      '<a href="https://example.com" target="_blank"><div class="editor-content-image" data-image=""><img src="/path/to/image.jpg" alt="Test image"></div></a>',
      editor
    );

    expect(editor.getHTML()).toMatchHtml(`
      <a href="https://example.com" target="_blank" rel="noopener noreferrer">
        <div class="editor-content-image" data-image="">
          <img src="/path/to/image.jpg" alt="Test image">
        </div>
      </a>
    `);
  });

  it("parses existing HTML with linked images without target", async () => {
    editorElement.focus();
    await updateContent(editorElement,
      '<a href="https://example.com"><div class="editor-content-image" data-image=""><img src="/path/to/image.jpg" alt="Test image"></div></a>',
      editor
    );

    expect(editor.getHTML()).toMatchHtml(`
      <a href="https://example.com">
        <div class="editor-content-image" data-image="">
          <img src="/path/to/image.jpg" alt="Test image">
        </div>
      </a>
    `);
  });

  it("allows updating image link attributes", async () => {
    editorElement.focus();
    editor.commands.setImage({ src: "/path/to/image.jpg", alt: "Test image", href: "https://example.com", target: "_blank" });
    await sleep(0);

    editor.commands.setImage({ src: "/path/to/image.jpg", alt: "Test image", href: "https://docs.example.com" });
    await sleep(0);

    expect(editor.getHTML()).toMatchHtml(`
      <a href="https://docs.example.com">
        <div class="editor-content-image" data-image="">
          <img src="/path/to/image.jpg" alt="Test image">
        </div>
      </a>
    `);
  });

  it("allows removing link from image", async () => {
    editorElement.focus();
    editor.commands.setImage({ src: "/path/to/image.jpg", alt: "Test image", href: "https://example.com", target: "_blank" });
    await sleep(0);

    editor.commands.setImage({ src: "/path/to/image.jpg", alt: "Test image", href: null, target: null });
    await sleep(0);

    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image="">
        <img src="/path/to/image.jpg" alt="Test image">
      </div>
    `);
  });

  it("renders images without links correctly", async () => {
    editorElement.focus();
    editor.commands.setImage({ src: "/path/to/image.jpg", alt: "Test image" });
    await sleep(0);

    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image="">
        <img src="/path/to/image.jpg" alt="Test image">
      </div>
    `);
  });
});
