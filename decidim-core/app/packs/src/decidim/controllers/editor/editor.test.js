/* global jest */

import { Application } from "@hotwired/stimulus";
import EditorController from "src/decidim/controllers/editor/controller";
import "src/decidim/editor/test/helpers";

jest.mock("images/decidim/remixicon.symbol.svg", () => "test/url.svg");

const sleep = (time = 0) => new Promise((resolve) => setTimeout(resolve, time));

class MockIntersectionObserver {
  static instances = [];

  constructor(callback) {
    this.callback = callback;
    MockIntersectionObserver.instances.push(this);
  }

  observe() {
    this.observed = true;
  }

  disconnect() {
    this.disconnected = true;
  }
}

describe("EditorController", () => {
  let application = null;
  let container = null;

  beforeEach(async () => {
    MockIntersectionObserver.instances = [];
    window.IntersectionObserver = MockIntersectionObserver;

    document.body.innerHTML = `
      <div class="editor">
        <input type="hidden" value="<p>Hello</p>" name="record[body]">
        <div class="editor-container" data-controller="editor" data-toolbar="basic" data-disabled="false" data-options="{&quot;context&quot;:&quot;admin&quot;}">
          <div class="editor-preview" data-editor-preview><p>Hello</p></div>
          <div class="editor-input" style="min-height: 10rem" hidden></div>
        </div>
      </div>
    `;

    container = document.querySelector(".editor-container");
    application = Application.start();
    application.register("editor", EditorController);

    await sleep();
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
  });

  it("does not initialize the editor until it is visible", () => {
    expect(document.querySelector(".ProseMirror")).toBeNull();
    expect(MockIntersectionObserver.instances[0].observed).toBe(true);
  });

  it("initializes the editor when it intersects the viewport", async () => {
    MockIntersectionObserver.instances[0].callback([{ isIntersecting: true }]);
    await sleep();

    expect(document.querySelector(".ProseMirror")).not.toBeNull();
    expect(container.querySelector(".editor-preview").hidden).toBe(true);
    expect(container.querySelector(".editor-input").hidden).toBe(false);
    expect(document.querySelector("input[type=hidden]").value).toEqual("<p>Hello</p>");
  });

  it("initializes the editor when it receives the reveal event", () => {
    container.dispatchEvent(new CustomEvent("editor:reveal", { bubbles: true }));

    expect(document.querySelector(".ProseMirror")).not.toBeNull();
  });

  it("dispatches editor:initialized when reusing an editor initialized before the controller connected", async () => {
    application.stop();

    document.body.innerHTML = `
      <div class="editor">
        <input type="hidden" value="<p>Hello</p>" name="record[body]">
        <div class="editor-container" data-controller="editor" data-toolbar="basic" data-disabled="false" data-options="{&quot;context&quot;:&quot;admin&quot;}">
          <div class="editor-preview" data-editor-preview><p>Hello</p></div>
          <div class="editor-input" style="min-height: 10rem" hidden>
            <div class="ProseMirror">Existing content</div>
          </div>
        </div>
      </div>
    `;

    const existingEditor = { commands: { setContent: jest.fn() } };
    document.querySelector(".ProseMirror").editor = existingEditor;
    container = document.querySelector(".editor-container");
    const listener = jest.fn();
    container.addEventListener("editor:initialized", listener);

    application = Application.start();
    application.register("editor", EditorController);
    await sleep();

    expect(listener).toHaveBeenCalledTimes(1);
    expect(listener.mock.calls[0][0].detail.editor).toBe(existingEditor);
  });

  it("dispatches editor:initialized when revealing an editor initialized before reveal", async () => {
    const listener = jest.fn();
    container.addEventListener("editor:initialized", listener);

    const existingEditor = { commands: { setContent: jest.fn() } };
    const proseMirror = document.createElement("div");
    proseMirror.classList.add("ProseMirror");
    proseMirror.editor = existingEditor;
    container.querySelector(".editor-input").appendChild(proseMirror);

    const controller = application.getControllerForElementAndIdentifier(container, "editor");

    expect(controller.reveal()).toBe(existingEditor);
    expect(listener).toHaveBeenCalledTimes(1);
    expect(listener.mock.calls[0][0].detail.editor).toBe(existingEditor);
  });

  it("reuses an editor initialized before the controller connected", async () => {
    application.stop();

    document.body.innerHTML = `
      <div class="editor">
        <input type="hidden" value="<p>Hello</p>" name="record[body]">
        <div class="editor-container" data-controller="editor" data-toolbar="basic" data-disabled="false" data-options="{&quot;context&quot;:&quot;admin&quot;}">
          <div class="editor-preview" data-editor-preview><p>Hello</p></div>
          <div class="editor-input" style="min-height: 10rem" hidden>
            <div class="ProseMirror">Existing content</div>
          </div>
        </div>
      </div>
    `;

    const existingEditor = { commands: { setContent: jest.fn() } };
    document.querySelector(".ProseMirror").editor = existingEditor;
    container = document.querySelector(".editor-container");

    application = Application.start();
    application.register("editor", EditorController);
    await sleep();

    const controller = application.getControllerForElementAndIdentifier(container, "editor");

    expect(controller.reveal()).toBe(existingEditor);
    expect(container.querySelectorAll(".ProseMirror")).toHaveLength(1);
    expect(container.dataset.editorInitialized).toBe("true");
    expect(container.querySelector(".editor-preview").hidden).toBe(true);
    expect(container.querySelector(".editor-input").hidden).toBe(false);
  });
});
