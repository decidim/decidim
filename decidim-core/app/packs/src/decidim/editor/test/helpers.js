/* global jest, __dirname */

import fs from "fs";
import path from "path";
import { Buffer } from "buffer";

// `escape-html` provided by the graphiql package
import escapeHTML from "escape-html";

// `mime-types` provided by webpack and form-data packages
import mime from "mime-types";

import { printDiffOrStringify } from "jest-matcher-utils";

import { Editor } from "@tiptap/core";
import { Document } from "@tiptap/extension-document";
import { Paragraph } from "@tiptap/extension-paragraph";
import { Text } from "@tiptap/extension-text";

import createEditor from "../index";

import editorMessages from "./fixtures/editor_messages";
import uploadTemplates from "./fixtures/upload_templates";

const config = { messages: { editor: editorMessages } };
window.Decidim = { config: { get: (key) => config[key] } };

const defaultEditorConfig = {
  contentTypes: {
    image: ["image/jpeg", "image/png"]
  },
  uploadImagesPath: "/editor_images",
  dragAndDropHelpText: "Add images by dragging & dropping or pasting them.",
  uploadDialogSelector: "#upload_dialog"
};

// Mock the SVG icons import because jest tests are not running through webpack
jest.mock("images/decidim/remixicon.symbol.svg", () => "test/url.svg");

// Custom expectations
expect.extend({
  toMatchHtml(received, expected) {
    // Removes the line breaks and indentation from the given HTML
    const uglyHTML = expected.replace(/[\r\n]+\s+/g, "");

    return {
      pass: received === uglyHTML,
      message: () => printDiffOrStringify(uglyHTML, received, "Expected", "Received", this.expand !== false)
    };
  }
});

// Fix issues with fetching the range
Object.assign(Range.prototype, {
  getBoundingClientRect: () => ({
    bottom: 0,
    height: 0,
    left: 0,
    right: 0,
    top: 0,
    width: 0
  }),
  getClientRects: () => ({
    item: () => null,
    length: 0,
    [Symbol.iterator]: jest.fn()
  })
});

export const sleep = async (time) => new Promise((resolve) => setTimeout(resolve, time));

export const updateContent = async (editable, content) => {
  // ProseMirror listens has a mutation observer which listens to the changes on
  // the contenteditable element. This forces us to manually change the
  // `innerHTML` of the element to cause a change event to be triggered for the
  // editor.
  editable.innerHTML = content;

  // We need to wait for the mutation observer to complete its logic. It has a
  // timeout of 20 milliseconds by default which is the minimum amount we need
  // to wait.
  await sleep(50);
};

export const selectContent = (editable, selector = null) => {
  editable.focus();

  if (selector) {
    document.getSelection().selectAllChildren(editable.querySelector(selector));
  } else {
    document.getSelection().selectAllChildren(editable);
  }

  document.dispatchEvent(new Event("selectionchange", { bubbles: true }));
};

export const selectRange = (editable, target, range = null) => {
  let selectionTarget = target;
  let selectionRange = range;
  if (range === null) {
    // If range is null the second parameter should be considered as range, so
    // we change that and set the target as the editable element itself.
    selectionTarget = editable;
    selectionRange = target;
  }

  const { start, end } = Object.assign({ start: null, end: null }, selectionRange);

  const domRange = new Range();
  if (start) {
    domRange.setStart(selectionTarget, start);
  } else if (end) {
    domRange.setStart(selectionTarget, end);
  }
  if (end) {
    domRange.setEnd(selectionTarget, end);
  } else if (start) {
    domRange.setEnd(selectionTarget, start);
  }

  editable.focus();
  const selection = document.getSelection();
  selection.removeAllRanges();
  selection.addRange(domRange);

  document.dispatchEvent(new Event("selectionchange", { bubbles: true }));
};

export const createBasicEditor = ({ extensions }) => {
  const element = document.createElement("div");
  element.classList.add("editor-input");
  document.body.append(element);

  return new Editor({
    element,
    content: "",
    extensions: [Document, Paragraph, Text, ...(extensions || [])]
  });
}

export const createEditorContainer = (options) => {
  const { design, toolbar, editorConfig, editorContent } = Object.assign({
    design: "redesign",
    toolbar: "full",
    editorConfig: {},
    editorContent: ""
  }, options);

  const finalConfig = Object.assign({}, defaultEditorConfig, editorConfig);
  const editorElement = `
    <div class="editor">
      <input autocomplete="off" type="hidden" value="${escapeHTML(editorContent)}" name="editor_input" id="editor_input" />
      <div class="editor-container" data-toolbar="${toolbar}" data-disabled="false" data-options="${escapeHTML(JSON.stringify(finalConfig))}">
        <div class="editor-input" style="height: 25rem"></div>
      </div>
    </div>
  `;
  const uploadElement = uploadTemplates[design];
  document.body.innerHTML = `${editorElement}${uploadElement}`;

  const editorContainer = document.querySelector(".editor-container");
  if (editorContainer) {
    createEditor(editorContainer);
  }
  return editorContainer;
};

export const fixtureFile = (filename, encoding = "utf8") => {
  return new Promise((resolve, reject) => {
    fs.readFile(path.join(__dirname, `fixtures/${filename}`), encoding, (err, data) => {
      if (err) {
        reject(err);
      } else {
        resolve(data);
      }
    })
  });
}

export const fixtureFileBuffer = async (filename, encoding = "utf8") => {
  return Buffer.from(await fixtureFile(filename, encoding), encoding);
}

export const dropFixtureFile = async (filename, target, options) => {
  const { encoding, type } = Object.assign({
    encoding: "utf8",
    type: mime.lookup(filename) || "text/plain"
  }, options)

  const file = new File(await fixtureFileBuffer(filename, encoding), filename, { type });
  const ev = new Event("drop");
  ev.dataTransfer = { files: [file] };
  target.dispatchEvent(ev);
  await sleep(0);
};
