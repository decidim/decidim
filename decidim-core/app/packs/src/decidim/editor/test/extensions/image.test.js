/* global jest, global */

import { createBasicEditor, updateContent, sleep, pasteFixtureFile, dropFixtureFile } from "../helpers";

import Dialog from "../../extensions/dialog";
import Image from "../../extensions/image";

/**
 * Replaces the UploadDialog implementation as that is not relevant regarding
 * testing the image extension.
 */
class DummyDialog {
  constructor() {
    this.dialogState = "save";
    this.values = {};
  }

  toggle() {
    return new Promise((resolve) => setTimeout(resolve(this.dialogState), 50));
  }

  setDialogState(state) {
    this.dialogState = state;
  }

  getValue(key) {
    return this.values[key];
  }

  setValues(values) {
    this.values = values;
  }
}

describe("Link", () => {
  let editor = null;
  let editorElement = null;
  let uploadDialog = new DummyDialog();

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor({
      extensions: [Dialog, Image.configure({
        uploadDialog,
        uploadImagesPath: "/editor_images",
        contentTypes: ["image/png"]
      })]
    });
    editorElement = editor.view.dom;

    // Append a dummy data-dialog element to the DOM so that the document is
    // recognized as "redesigned" by the input dialog.
    const dummy = document.createElement("div");
    dummy.dataset.dialog = "";
    document.body.append(dummy);

    // Add a CSRF token for image uploads handling
    const csrf = document.createElement("meta");
    csrf.setAttribute("name", "csrf-token")
    csrf.setAttribute("content", "abcdef0123456789")
    document.head.append(csrf);

    // Mocks the fetch method for the dynamic upload
    global.fetch = jest.fn(() =>
      Promise.resolve({ ok: true, json: () => Promise.resolve({ url: "/path/to/logo.png" }) })
    );
  });

  afterEach(() => {
    uploadDialog.setDialogState("save");
    uploadDialog.setValues({});
  });

  it("allows setting the image through the dialog", async () => {
    uploadDialog.setValues({
      src: "/path/to/image.jpg",
      alt: "Test text"
    });

    editor.commands.imageDialog();
    expect(editorElement.classList.contains("dialog-open")).toBe(true);
    await sleep(55);
    expect(editorElement.classList.contains("dialog-open")).toBe(false);

    expect(editorElement.innerHTML).toMatchHtml(`
      <div data-image-resizer="" class="ProseMirror-selectednode" draggable="true">
        <div data-image-resizer-wrapper="">
          <div data-image-resizer-control="top-left"></div>
          <div data-image-resizer-control="top-right"></div>
          <div data-image-resizer-control="bottom-left"></div>
          <div data-image-resizer-control="bottom-right"></div>
          <div class="editor-content-image" data-image="">
            <img src="/path/to/image.jpg" alt="Test text">
          </div>
        </div>
      </div>
    `);
    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image="">
        <img src="/path/to/image.jpg" alt="Test text">
      </div>
    `);
  });

  it("editing setting the image through the dialog", async () => {
    editorElement.focus();
    await updateContent(editorElement,
      '<div class="editor-content-image" data-image=""><img src="/path/to/image.jpg" alt="Test text"></div>'
    );

    uploadDialog.setValues({
      src: "/path/to/image_updated.jpg",
      alt: "Updated text"
    });

    editor.commands.imageDialog();
    expect(editorElement.classList.contains("dialog-open")).toBe(true);
    await sleep(55);
    expect(editorElement.classList.contains("dialog-open")).toBe(false);

    expect(editorElement.innerHTML).toMatchHtml(`
      <div data-image-resizer="" class="ProseMirror-selectednode" draggable="true">
        <div data-image-resizer-wrapper="">
          <div data-image-resizer-control="top-left"></div>
          <div data-image-resizer-control="top-right"></div>
          <div data-image-resizer-control="bottom-left"></div>
          <div data-image-resizer-control="bottom-right"></div>
          <div class="editor-content-image" data-image="">
            <img src="/path/to/image_updated.jpg" alt="Updated text">
          </div>
        </div>
      </div>
    `);
    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image="">
        <img src="/path/to/image_updated.jpg" alt="Updated text">
      </div>
    `);
  });

  it("allows double clicking the image", async () => {
    editorElement.focus();
    await updateContent(editorElement,
      '<div class="editor-content-image" data-image=""><img src="/path/to/image.jpg" alt="Test text"></div>'
    );

    uploadDialog.setValues({
      src: "/path/to/image_updated.jpg",
      alt: "Updated text"
    });

    jest.spyOn(uploadDialog, "toggle");

    // Position calculations do not work with JSDom / Jest
    editor.view.posAtCoords = jest.fn().mockReturnValue({ pos: 1, inside: -1 });

    editorElement.dispatchEvent(new MouseEvent("mousedown", { clientX: 10, clientY: 10 }));
    editorElement.dispatchEvent(new MouseEvent("mousedown", { clientX: 10, clientY: 10 }));
    await sleep(55);

    expect(uploadDialog.toggle).toHaveBeenCalled();
    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image="">
        <img src="/path/to/image_updated.jpg" alt="Updated text">
      </div>
    `);
  });

  it("allows pasting an image", async () => {
    editorElement.focus();
    await pasteFixtureFile(editorElement, "logo.png");

    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image="">
        <img src="/path/to/logo.png" alt="logo">
      </div>
    `);
  });

  it("allows dropping an image", async () => {
    editorElement.focus();

    // Position calculations do not work with JSDom / Jest
    editor.view.posAtCoords = jest.fn().mockReturnValue({ pos: 1, inside: -1 });

    await dropFixtureFile(editorElement, "logo.png");

    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image="">
        <img src="/path/to/logo.png" alt="logo">
      </div>
    `);
  });
});
