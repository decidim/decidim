/* global jest, global */

import { createBasicEditor, updateContent } from "../helpers";

import Mention from "../../extensions/mention";

const mentionsResponse = [
  {
    nickname: "@johndoe",
    name: "John Doe",
    avatarUrl: "/avatars/johndoe.jpg",
    __typename: "User"
  },
  {
    nickname: "@joannadoe",
    name: "Joanna Doe",
    avatarUrl: "/avatars/joannadoe.jpg",
    __typename: "User"
  },
  {
    nickname: "@joedoe",
    name: "Joe Doe",
    avatarUrl: "/avatars/joedoe.jpg",
    __typename: "User"
  },
  {
    nickname: "@marydoe",
    name: "Mary Doe",
    avatarUrl: "/avatars/marydoe.jpg",
    __typename: "User"
  },
  {
    nickname: "@mickdoe",
    name: "Mick Doe",
    avatarUrl: "/avatars/mickdoe.jpg",
    __typename: "User"
  },
  {
    nickname: "@mikedoe",
    name: "Mike Doe",
    avatarUrl: "/avatars/mikedoe.jpg",
    __typename: "User"
  }
];

global.fetch = jest.fn(
  (url, options) => Promise.resolve({
    ok: true,
    json: () => {
      const { query } = JSON.parse(options.body);
      const queryMatch = query.replace(/\n/g, "").match(/\{\s+users\(filter: \{ wildcard: "([^"]+)" \}\) \{.*/);

      let filteredData = [];
      if (queryMatch) {
        filteredData = mentionsResponse.filter((val) => val.nickname.match(new RegExp(`^@${queryMatch[1]}`)));
      }

      return Promise.resolve({ data: { users: filteredData } });
    }
  })
);

describe("Mention", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor({ extensions: [Mention] })
    editorElement = editor.view.dom;
  });

  it("creates the mention suggestions when suggestion key is entered", async () => {
    editorElement.focus();
    await updateContent(editorElement, "@jo");

    const suggestions = document.querySelector(".editor-suggestions");
    expect(suggestions).toBeInstanceOf(HTMLDivElement);

    const expectedTags = ["@johndoe (John Doe)", "@joannadoe (Joanna Doe)", "@joedoe (Joe Doe)"];

    const items = suggestions.querySelectorAll(".editor-suggestions-item");
    expect(items.length).toEqual(expectedTags.length);
    for (const item of items) {
      expect(expectedTags.includes(item.textContent)).toBe(true);
    }
  });

  it("does not display the suggestions when less than two characters are entered", async () => {
    editorElement.focus();
    await updateContent(editorElement, "@j");

    const suggestions = document.querySelector(".editor-suggestions");
    expect(suggestions).toBeInstanceOf(HTMLDivElement);
    expect(suggestions.childNodes.length).toBe(0);
    expect(suggestions.classList.contains("hidden")).toBe(true);
    expect(suggestions.classList.contains("hide")).toBe(true);
  });

  it("allows selecting a mention from the list by clicking it", async () => {
    editorElement.focus();
    await updateContent(editorElement, "@joh");

    const suggestions = document.querySelector(".editor-suggestions");
    suggestions.querySelector(".editor-suggestions-item").click();

    expect(editorElement.innerHTML).toEqual(
      '<p><span data-suggestion="mention" data-id="@johndoe" data-label="@johndoe (John Doe)">@johndoe (John Doe)</span> </p>'
    );
    expect(editor.getHTML()).toEqual(
      '<p><span data-type="mention" data-id="@johndoe" data-label="@johndoe (John Doe)">@johndoe (John Doe)</span> </p>'
    );
  });

  it("allows selecting a mention from the list by clicking the Enter key", async () => {
    editorElement.focus();
    await updateContent(editorElement, "@joh");

    editorElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Enter" }));

    expect(editorElement.innerHTML).toEqual(
      '<p><span data-suggestion="mention" data-id="@johndoe" data-label="@johndoe (John Doe)">@johndoe (John Doe)</span> </p>'
    );
    expect(editor.getHTML()).toEqual(
      '<p><span data-type="mention" data-id="@johndoe" data-label="@johndoe (John Doe)">@johndoe (John Doe)</span> </p>'
    );
  });
});
