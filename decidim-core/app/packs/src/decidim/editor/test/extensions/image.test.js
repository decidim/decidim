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

describe("Image", () => {
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

    jest.restoreAllMocks();
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
          <div data-image-resizer-dimensions="">
            <span data-image-resizer-dimension="width" data-image-resizer-dimension-value=""></span>
            ×
            <span data-image-resizer-dimension="height" data-image-resizer-dimension-value=""></span>
          </div>
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
          <div data-image-resizer-dimensions="">
            <span data-image-resizer-dimension="width" data-image-resizer-dimension-value="null"></span>
            ×
            <span data-image-resizer-dimension="height" data-image-resizer-dimension-value="null"></span>
          </div>
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

  describe("resizing", () => {
    const behavesLikeImageResizer = (dragMode) => {
      const simulateDrag = (moveControl, { from, to }) => {
        if (dragMode === "touch") {
          moveControl.dispatchEvent(new MouseEvent("touchstart", { clientX: from, clientY: 0 }));
          document.dispatchEvent(new MouseEvent("touchmove", { clientX: to, clientY: 0 }));
          document.dispatchEvent(new MouseEvent("touchend"));
        } else {
          moveControl.dispatchEvent(new MouseEvent("mousedown", { clientX: from, clientY: 0 }));
          document.dispatchEvent(new MouseEvent("mousemove", { clientX: to, clientY: 0 }));
          document.dispatchEvent(new MouseEvent("mouseup"));
        }
      };

      it("putputs and updates the dimensions of the element", () => {
        expect(editorElement.querySelector("[data-image-resizer-dimensions]").innerHTML).toEqual(
          '<span data-image-resizer-dimension="width" data-image-resizer-dimension-value="600"></span>×<span data-image-resizer-dimension="height" data-image-resizer-dimension-value="800"></span>'
        );
        const topRight = editorElement.querySelector("[data-image-resizer-control='top-right']");
        simulateDrag(topRight, { from: 800, to: 700 });
        expect(editorElement.querySelector("img").outerHTML).toEqual(
          '<img src="/path/to/image.jpg" alt="Test text" width="500">'
        );
        expect(editorElement.querySelector("[data-image-resizer-dimensions]").innerHTML).toEqual(
          '<span data-image-resizer-dimension="width" data-image-resizer-dimension-value="500"></span>×<span data-image-resizer-dimension="height" data-image-resizer-dimension-value="667"></span>'
        );
      })

      it("allows resizing the image down using the right side controls", () => {
        const topRight = editorElement.querySelector("[data-image-resizer-control='top-right']");
        simulateDrag(topRight, { from: 800, to: 700 });
        expect(editorElement.querySelector("img").outerHTML).toEqual(
          '<img src="/path/to/image.jpg" alt="Test text" width="500">'
        );
        expect(editorElement.querySelector("[data-image-resizer-dimensions]").innerHTML).toEqual(
          '<span data-image-resizer-dimension="width" data-image-resizer-dimension-value="500"></span>×<span data-image-resizer-dimension="height" data-image-resizer-dimension-value="667"></span>'
        );

        const bottomRight = editorElement.querySelector("[data-image-resizer-control='bottom-right']");
        simulateDrag(bottomRight, { from: 700, to: 750 });
        expect(editorElement.querySelector("img").outerHTML).toEqual(
          '<img src="/path/to/image.jpg" alt="Test text" width="550">'
        );
      });

      it("allows resizing the image down using the left side controls", () => {
        const topLeft = editorElement.querySelector("[data-image-resizer-control='top-left']");
        simulateDrag(topLeft, { from: 200, to: 300 });
        expect(editorElement.querySelector("img").outerHTML).toEqual(
          '<img src="/path/to/image.jpg" alt="Test text" width="500">'
        );

        const bottomLeft = editorElement.querySelector("[data-image-resizer-control='bottom-left']");
        simulateDrag(bottomLeft, { from: 200, to: 150 });
        expect(editorElement.querySelector("img").outerHTML).toEqual(
          '<img src="/path/to/image.jpg" alt="Test text" width="550">'
        );
      });

      it("removes the width attribute when the image reaches its natural width", () => {
        const topRight = editorElement.querySelector("[data-image-resizer-control='top-right']");
        simulateDrag(topRight, { from: 800, to: 700 });
        expect(editorElement.querySelector("img").outerHTML).toEqual(
          '<img src="/path/to/image.jpg" alt="Test text" width="500">'
        );

        simulateDrag(topRight, { from: 700, to: 1500 });
        expect(editorElement.querySelector("img").outerHTML).toEqual(
          '<img src="/path/to/image.jpg" alt="Test text">'
        );
      });

      it("does not allow making the image smaller than 100px", () => {
        const bottomLeft = editorElement.querySelector("[data-image-resizer-control='bottom-left']");
        simulateDrag(bottomLeft, { from: 200, to: 1500 });
        expect(editorElement.querySelector("img").outerHTML).toEqual(
          '<img src="/path/to/image.jpg" alt="Test text" width="100">'
        );

        const bottomRight = editorElement.querySelector("[data-image-resizer-control='bottom-right']");
        simulateDrag(bottomRight, { from: 300, to: 200 });
        expect(editorElement.querySelector("img").outerHTML).toEqual(
          '<img src="/path/to/image.jpg" alt="Test text" width="100">'
        );
      });
    }

    beforeEach(async () => {
      // Mock the createElement method so that we can mock the image natural
      // width used by the resizer.
      const originalCreate = document.createElement;
      jest.spyOn(document, "createElement").mockImplementation((...args) => {
        const element = Reflect.apply(originalCreate, document, args);
        if (element.nodeName === "IMG") {
          // Mock the `naturalWidth` getter on the <img> element
          jest.spyOn(element, "naturalWidth", "get").mockReturnValue(600);
          jest.spyOn(element, "naturalHeight", "get").mockReturnValue(800);

          // Mock the `onload` setter on the <img> element to call it correctly
          jest.spyOn(element, "onload", "set").mockImplementation((callback) => {
            if (callback instanceof Function) {
              return Reflect.apply(callback, element, []);
            }
            return null;
          });
        }

        return element;
      });

      editorElement.focus();
      await updateContent(editorElement,
        '<div class="editor-content-image" data-image=""><img src="/path/to/image.jpg" alt="Test text"></div>'
      );
    });

    describe("with mouse", () => behavesLikeImageResizer("mouse"));

    describe("with touch", () => behavesLikeImageResizer("touch"));
  })
});
