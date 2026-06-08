/* global global, jest */
/**
 * @jest-environment jsdom
 */

import { Application } from "@hotwired/stimulus"
import MentionController from "src/decidim/controllers/mention/controller";

global.fetch = jest.fn();

global.window.Decidim = {
  config: {
    get: jest.fn()
  }
};

describe("MentionController", () => {
  let application = null;
  let mockElement = null;
  let controller = null;

  beforeEach(() => {
    application = Application.start();
    application.register("mention", MentionController);
    jest.clearAllMocks();

    document.body.innerHTML = `
      <div class="mention-container">
        <input data-noresults="No users found" data-controller="mention" />
      </div>
    `;

    mockElement = document.querySelector("[data-controller='mention']");

    window.Decidim.config.get.mockReturnValue("http://localhost:3000/api");

    fetch.mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({
        data: {
          users: [
            {
              nickname: "@doe_john",
              name: "John Doe",
              avatarUrl: "http://example.com/avatar.jpg",
              __typename: "User"
            }
          ]
        }
      })
    });
  });

  afterEach(() => {
    controller?.disconnect();
    document.body.innerHTML = "";
    application.stop();
    jest.restoreAllMocks();
  });

  const connectController = () => {
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(mockElement, "mention");
        resolve();
      }, 0);
    });
  };

  const waitForDebounce = () => {
    return new Promise((resolve) => setTimeout(resolve, 300));
  };

  it("initializes when not inside editor", async () => {
    await connectController();

    expect(controller.initialized).toBe(true);
    expect(document.querySelector(".editor-suggestions")).toBeInstanceOf(HTMLDivElement);
  });

  it("does not initialize when inside editor", async () => {
    const editorContainer = document.createElement("div");
    editorContainer.classList.add("editor");
    const editorElement = document.createElement("input");
    editorElement.setAttribute("data-controller", "mention");
    editorContainer.appendChild(editorElement);
    document.body.appendChild(editorContainer);

    await new Promise((resolve) => setTimeout(resolve, 0));

    const editorController = application.getControllerForElementAndIdentifier(editorElement, "mention");
    expect(editorController.initialized).toBe(false);
    expect(editorController.suggestion).toBeNull();
  });

  it("shows suggestions for valid mention query", async () => {
    await connectController();

    mockElement.value = "Hello @do";
    mockElement.setSelectionRange(mockElement.value.length, mockElement.value.length);
    mockElement.dispatchEvent(new Event("input", { bubbles: true }));

    await waitForDebounce();

    const suggestions = document.querySelector(".editor-suggestions");
    const items = suggestions.querySelectorAll(".editor-suggestions-item");

    expect(items.length).toBe(1);
    expect(items[0].querySelector(".editor-suggestions-item-avatar")).toBeInstanceOf(HTMLImageElement);
    expect(items[0].querySelector(".editor-suggestions-item-label").textContent).toBe("@doe_john (John Doe)");
    expect(suggestions.classList.contains("hidden")).toBe(false);
  });

  it("does not show suggestions when fewer than two mention characters", async () => {
    await connectController();

    mockElement.value = "Hello @d";
    mockElement.setSelectionRange(mockElement.value.length, mockElement.value.length);
    mockElement.dispatchEvent(new Event("input", { bubbles: true }));

    await waitForDebounce();

    const suggestions = document.querySelector(".editor-suggestions");
    expect(suggestions.classList.contains("hidden")).toBe(true);
  });

  it("inserts selected mention on click", async () => {
    await connectController();

    mockElement.value = "Hello @do";
    mockElement.setSelectionRange(mockElement.value.length, mockElement.value.length);
    mockElement.dispatchEvent(new Event("input", { bubbles: true }));

    await waitForDebounce();

    const suggestionItem = document.querySelector(".editor-suggestions-item");
    suggestionItem.click();

    expect(mockElement.value).toBe("Hello @doe_john ");
    expect(document.querySelector(".editor-suggestions").classList.contains("hidden")).toBe(true);
  });

  it("supports keyboard navigation and enter selection", async () => {
    await connectController();

    fetch.mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({
        data: {
          users: [
            { nickname: "@alpha", name: "Alpha", avatarUrl: "", __typename: "User" },
            { nickname: "@bravo", name: "Bravo", avatarUrl: "", __typename: "User" }
          ]
        }
      })
    });

    mockElement.value = "Hello @ab";
    mockElement.setSelectionRange(mockElement.value.length, mockElement.value.length);
    mockElement.dispatchEvent(new Event("input", { bubbles: true }));
    await waitForDebounce();

    mockElement.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowDown", bubbles: true }));
    mockElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Enter", bubbles: true }));

    expect(mockElement.value).toBe("Hello @bravo ");
  });

  it("positions suggestions near the mention trigger character", async () => {
    await connectController();

    mockElement.value = "A long text before @do";
    mockElement.setSelectionRange(mockElement.value.length, mockElement.value.length);
    mockElement.dispatchEvent(new Event("input", { bubbles: true }));
    await waitForDebounce();

    const suggestions = document.querySelector(".editor-suggestions");

    expect(suggestions.style.position).toBe("absolute");
    expect(suggestions.style.top).toMatch(/\d+px/);
    expect(suggestions.style.left).toMatch(/\d+px/);
  });

  it("shows no results message when API returns empty list", async () => {
    await connectController();

    fetch.mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ data: { users: [] } })
    });

    mockElement.value = "Hello @zz";
    mockElement.setSelectionRange(mockElement.value.length, mockElement.value.length);
    mockElement.dispatchEvent(new Event("input", { bubbles: true }));
    await waitForDebounce();

    const noResultsItem = document.querySelector(".editor-suggestions-item");
    expect(noResultsItem).toBeInstanceOf(HTMLButtonElement);
    expect(noResultsItem.textContent).toBe("No users found");
    expect(noResultsItem.disabled).toBe(true);
  });

  it("hides suggestions on escape", async () => {
    await connectController();

    mockElement.value = "Hello @do";
    mockElement.setSelectionRange(mockElement.value.length, mockElement.value.length);
    mockElement.dispatchEvent(new Event("input", { bubbles: true }));
    await waitForDebounce();

    mockElement.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }));

    const suggestions = document.querySelector(".editor-suggestions");
    expect(suggestions.classList.contains("hidden")).toBe(true);
  });

  it("cleans up on disconnect", async () => {
    await connectController();

    controller.disconnect();

    expect(controller.suggestion).toBeNull();
    expect(controller.initialized).toBe(false);
  });
});
