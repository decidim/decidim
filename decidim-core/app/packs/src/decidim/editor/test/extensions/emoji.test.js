/* eslint-disable no-undef */

import { Application } from "@hotwired/stimulus"
import EmojiController from "src/decidim/controllers/emoji/controller";
import { createBasicEditor, sleep } from "src/decidim/editor/test/helpers";

import Emoji from "src/decidim/editor/extensions/emoji";

Reflect.defineProperty(window, "matchMedia", {
  writable: true,
  value: jest.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn()
  }))
});

describe("Emoji", () => {
  let application = null;
  let controller = null;

  beforeEach(async () => {
    application = Application.start();
    application.register("emoji", EmojiController);

    document.body.innerHTML = "";

    createBasicEditor({ extensions: [Emoji] })

    // Wait the event loop to finish creating the emoji picker
    await sleep(0);

    let mockElement = document.querySelector("[data-controller='emoji']")
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(mockElement, "emoji");
        resolve();
      }, 0);
    });
  });

  it("creates the emoji button for the editor", () => {
    expect(controller).toBeDefined()
    expect(document.querySelector(".editor-input .emoji__container")).toBeInstanceOf(HTMLElement);
    expect(document.querySelector(".editor-input .emoji__trigger button.emoji__button")).toBeInstanceOf(HTMLElement);
  });
});
