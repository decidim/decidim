/* global jest, global */

import { createBasicEditor, updateContent, sleep, pasteFixtureFile, dropFixtureFile } from "../helpers";

import Dialog from "../../extensions/dialog";
import Image from "../../extensions/image";
import uploadTemplates from "../fixtures/upload_templates";

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

describe("Image", () => {
  let editor = null;
  let editorElement = null;
  let uploadFilePath = "/path/to/image.jpg";
  let uploadDialogElement = null;
  let editorInnerHTML = (dim, src, alt) => {
    return `
    <div data-image-resizer="" class="ProseMirror-selectednode" draggable="true">
      <div data-image-resizer-wrapper="">
        <button type="button" data-image-resizer-control="top-left"></button>
        <button type="button" data-image-resizer-control="top-right"></button>
        <button type="button" data-image-resizer-control="bottom-left"></button>
        <button type="button" data-image-resizer-control="bottom-right"></button>
        <div data-image-resizer-dimensions="">
          <span data-image-resizer-dimension="width" data-image-resizer-dimension-value="${dim}"></span>
          ×
          <span data-image-resizer-dimension="height" data-image-resizer-dimension-value="${dim}"></span>
        </div>
        <div class="editor-content-image" data-image="">
          <img src="${src}" alt="${alt}">
        </div>
      </div>
    </div>
  `
  }

  const updateFile = async (path, alt) => {
    uploadFilePath = path;
    const dz = uploadDialogElement.querySelector("[data-dropzone]");
    dz.files = [{ name: "image.jpg" }];
    dz.dispatchEvent(new CustomEvent("change"));
    await sleep(0);

    uploadDialogElement.querySelector("input[name='alt']").value = alt;

    uploadDialogElement.querySelector("[data-dropzone-save]").click();
    uploadDialogElement.dispatchEvent(new CustomEvent("close.dialog"));

    await sleep(0);
  }

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

    // Add a CSRF token for image uploads handling
    const csrf = document.createElement("meta");
    csrf.setAttribute("name", "csrf-token")
    csrf.setAttribute("content", "abcdef0123456789")
    document.head.append(csrf);

    // Mocks the fetch method for the dynamic upload
    global.fetch = jest.fn(() => Promise.resolve({ ok: true, json: () => Promise.resolve({ url: uploadFilePath }) }));
  });

  afterEach(() => {
    uploadFilePath = "/path/to/image.jpg";
    jest.restoreAllMocks();
  });

  it("allows setting the image through the dialog", async () => {
    editor.commands.imageDialog();
    expect(editorElement.classList.contains("dialog-open")).toBe(true);
    await updateFile("/path/to/image.jpg", "Test text")
    expect(editorElement.classList.contains("dialog-open")).toBe(false);

    expect(editorElement.innerHTML).toMatchHtml(editorInnerHTML("", "/path/to/image.jpg", "Test text"));
    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image=""><img src="/path/to/image.jpg" alt="Test text"></div>
    `);
  });

  it("editing setting the image through the dialog", async () => {
    editorElement.focus();
    await updateContent(editorElement,
      '<div class="editor-content-image" data-image=""><img src="/path/to/image.jpg" alt="Test text"></div>'
    );

    editor.commands.imageDialog();
    expect(editorElement.classList.contains("dialog-open")).toBe(true);
    await updateFile("/path/to/image_updated.jpg", "Updated text")
    expect(editorElement.classList.contains("dialog-open")).toBe(false);

    expect(editorElement.innerHTML).toMatchHtml(editorInnerHTML("null", "/path/to/image_updated.jpg", "Updated text"));
    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image=""><img src="/path/to/image_updated.jpg" alt="Updated text"></div>
    `);
  });

  it("allows double clicking the image", async () => {
    editorElement.focus();
    await updateContent(editorElement,
      '<div class="editor-content-image" data-image=""><img src="/path/to/image.jpg" alt="Test text"></div>'
    );

    jest.spyOn(uploadDialogElement.dialog, "open");

    // Position calculations do not work with JSDom / Jest
    editor.view.posAtCoords = jest.fn().mockReturnValue({ pos: 1, inside: -1 });
    editorElement.dispatchEvent(new MouseEvent("mousedown", { button: 0, clientX: 10, clientY: 10 }));
    editorElement.dispatchEvent(new MouseEvent("mousedown", { button: 0, clientX: 10, clientY: 10 }));
    await updateFile("/path/to/image_updated.jpg", "Updated text")

    expect(uploadDialogElement.dialog.open).toHaveBeenCalled();
    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-image" data-image="">
        <img src="/path/to/image_updated.jpg" alt="Updated text">
      </div>
    `);
  });

  it("allows pasting an image", async () => {
    editorElement.focus();
    uploadFilePath = "/path/to/logo.png";
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
    uploadFilePath = "/path/to/logo.png";
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
          moveControl.dispatchEvent(new TouchEvent("touchstart", { touches: [new Touch({ pageX: from, pageY: 0 })] }));
          document.dispatchEvent(new TouchEvent("touchmove", { touches: [new Touch({ pageX: to, pageY: 0 })] }));
          document.dispatchEvent(new TouchEvent("touchend"));
        } else {
          moveControl.dispatchEvent(new MouseEvent("mousedown", { button: 0, clientX: from, clientY: 0 }));
          document.dispatchEvent(new MouseEvent("mousemove", { clientX: to, clientY: 0 }));
          document.dispatchEvent(new MouseEvent("mouseup", { button: 0 }));
        }
      };

      it("updates the dimensions of the element", () => {
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
  });
});
