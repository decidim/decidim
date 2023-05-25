/* global jest, global */

import { createBasicEditor, updateContent } from "../helpers";

import Hashtag from "../../extensions/hashtag";

const hashtagsResponse = [
  { name: "apples" },
  { name: "bananas" },
  { name: "lemons" },
  { name: "limes" },
  { name: "loganberries" },
  { name: "longans" },
  { name: "loquats" },
  { name: "mangosteens" },
  { name: "oranges" },
  { name: "peaches" },
  { name: "pineapples" },
  { name: "pomelos" }
];

global.fetch = jest.fn(
  (url, options) => Promise.resolve({
    ok: true,
    json: () => {
      const { query } = JSON.parse(options.body);
      const queryMatch = query.match(/\{\s+hashtags\(name:"([^"]+)"\) \{name\}\s+\}/);

      let filteredData = [];
      if (queryMatch) {
        filteredData = hashtagsResponse.filter((val) => val.name.match(new RegExp(`^${queryMatch[1]}`)));
      }

      return Promise.resolve({ data: { hashtags: filteredData } });
    }
  })
);

describe("Hashtag", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor({ extensions: [Hashtag] })
    editorElement = editor.view.dom;
  });

  it("creates the hashtag suggestions when suggestion key is entered", async () => {
    editorElement.focus();
    await updateContent(editorElement, "#lo");

    const suggestions = document.querySelector(".editor-suggestions");
    expect(suggestions).toBeInstanceOf(HTMLDivElement);

    const expectedTags = ["#loganberries", "#longans", "#loquats"];

    const items = suggestions.querySelectorAll(".editor-suggestions-item");
    expect(items.length).toEqual(expectedTags.length);
    for (const item of items) {
      expect(expectedTags.includes(item.textContent)).toBe(true);
    }
  });

  it("does not display the suggestions when less than two characters are entered", async () => {
    editorElement.focus();
    await updateContent(editorElement, "#l");

    const suggestions = document.querySelector(".editor-suggestions");
    expect(suggestions).toBeInstanceOf(HTMLDivElement);
    expect(suggestions.childNodes.length).toBe(0);
    expect(suggestions.classList.contains("hidden")).toBe(true);
    expect(suggestions.classList.contains("hide")).toBe(true);
  });

  it("allows selecting a hashtag from the list by clicking it", async () => {
    editorElement.focus();
    await updateContent(editorElement, "#log");

    const suggestions = document.querySelector(".editor-suggestions");
    suggestions.querySelector(".editor-suggestions-item").click();

    expect(editorElement.innerHTML).toEqual(
      '<p><span data-suggestion="hashtag" data-label="#loganberries">#loganberries</span> </p>'
    );
    expect(editor.getHTML()).toEqual(
      '<p><span data-type="hashtag" data-label="#loganberries">#loganberries</span> </p>'
    );
  });

  it("allows selecting a hashtag from the list by clicking the Enter key", async () => {
    editorElement.focus();
    await updateContent(editorElement, "#log");

    editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Enter" }));

    expect(editorElement.innerHTML).toEqual(
      '<p><span data-suggestion="hashtag" data-label="#loganberries">#loganberries</span> </p>'
    );
    expect(editor.getHTML()).toEqual(
      '<p><span data-type="hashtag" data-label="#loganberries">#loganberries</span> </p>'
    );
  });
});
