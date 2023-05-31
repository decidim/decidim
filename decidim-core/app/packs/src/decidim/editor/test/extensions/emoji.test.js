import { createBasicEditor, sleep } from "../helpers";

import Emoji from "../../extensions/emoji";

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
