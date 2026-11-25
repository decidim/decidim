/* global jest */

import { Application } from "@hotwired/stimulus";
import CharacterCounterController from "src/decidim/controllers/character_counter/controller";

jest.mock("src/decidim/refactor/moved/i18n", () => ({
  getMessages: jest.fn((key) => {
    const messages = {
      "characterCounter.charactersAtLeast.one": "At least 1 character.",
      "characterCounter.charactersAtLeast.other": "At least %count% characters.",
      "characterCounter.charactersLeft.one": "1 character left.",
      "characterCounter.charactersLeft.other": "%count% characters left."
    };

    return messages[key] || key;
  })
}));

const sleep = (time = 0) => new Promise((resolve) => setTimeout(resolve, time));

const createMockEditor = () => {
  const dom = document.createElement("div");
  dom.className = "ProseMirror";
  dom.setAttribute("contenteditable", "true");

  return {
    view: { dom },
    storage: { characterCount: { characters: () => 5 } },
    on: jest.fn()
  };
};

describe("CharacterCounterController", () => {
  let application = null;
  let editorContainer = null;
  let input = null;
  let controller = null;

  beforeEach(async () => {
    document.body.innerHTML = `
      <div class="editor">
        <input
          type="hidden"
          id="record_body"
          value="Hello"
          maxlength="100"
          data-controller="character-counter"
        >
      </div>
    `;

    application = Application.start();
    application.register("character-counter", CharacterCounterController);

    editorContainer = document.querySelector(".editor");
    input = document.querySelector('[data-controller="character-counter"]');

    await sleep();

    controller = application.getControllerForElementAndIdentifier(input, "character-counter");
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
    jest.clearAllMocks();
  });

  it("binds the counter events when the editor is initialized", () => {
    const editor = createMockEditor();

    editorContainer.dispatchEvent(
      new CustomEvent("editor:initialized", { detail: { editor } })
    );

    expect(controller.editor).toBe(editor);
    expect(controller.userInput).toBe(editor.view.dom);
    expect(editor.on).toHaveBeenCalledTimes(1);
    expect(editor.on).toHaveBeenCalledWith("update", expect.any(Function));
  });

  it("removes the editor initialization listener on disconnect", () => {
    controller.disconnect();

    const editor = createMockEditor();

    editorContainer.dispatchEvent(
      new CustomEvent("editor:initialized", { detail: { editor } })
    );

    expect(controller.editor).toBeUndefined();
    expect(editor.on).not.toHaveBeenCalled();
  });

  it("does not bind the counter events twice when reconnecting before initialization", () => {
    controller.disconnect();
    controller.connect();

    const editor = createMockEditor();
    const addEventListener = jest.spyOn(editor.view.dom, "addEventListener");

    editorContainer.dispatchEvent(
      new CustomEvent("editor:initialized", { detail: { editor } })
    );

    expect(editor.on).toHaveBeenCalledTimes(1);
    expect(addEventListener.mock.calls.filter(([name]) => name === "keyup")).toHaveLength(1);
  });

  it("does not bind the counter events again when the same editor is announced twice", () => {
    const editor = createMockEditor();
    const addEventListener = jest.spyOn(editor.view.dom, "addEventListener");

    editorContainer.dispatchEvent(
      new CustomEvent("editor:initialized", { detail: { editor } })
    );
    editorContainer.dispatchEvent(
      new CustomEvent("editor:initialized", { detail: { editor } })
    );

    expect(editor.on).toHaveBeenCalledTimes(1);
    expect(addEventListener.mock.calls.filter(([name]) => name === "keyup")).toHaveLength(1);
  });

  it("keeps the fallback lookup for editors initialized before the event", async () => {
    controller.disconnect();

    const editor = createMockEditor();
    const proseMirror = editor.view.dom;
    proseMirror.editor = editor;

    const fallbackContainer = document.createElement("div");
    fallbackContainer.className = "editor-container";
    fallbackContainer.appendChild(proseMirror);
    input.parentElement.appendChild(fallbackContainer);

    controller.connect();
    await sleep();

    expect(controller.editor).toBe(editor);
    expect(controller.userInput).toBe(proseMirror);
    expect(editor.on).toHaveBeenCalledTimes(1);
  });
});
