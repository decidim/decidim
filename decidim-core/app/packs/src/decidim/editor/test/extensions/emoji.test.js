/* eslint-disable no-undef */

import { createBasicEditor, sleep } from "../helpers";

import Emoji from "../../extensions/emoji";

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
  beforeEach(async () => {
    document.body.innerHTML = "";

    createBasicEditor({ extensions: [Emoji] })

    // Wait the event loop to finish creating the emoji picker
    await sleep(0);
  });

  it("creates the emoji button for the editor", () => {
    expect(document.querySelector(".editor-input .emoji__container")).toBeInstanceOf(HTMLElement);
    expect(document.querySelector(".editor-input .emoji__trigger button.emoji__button")).toBeInstanceOf(HTMLElement);
  });
});
