/* eslint max-lines: ["error", 775] , id-length: 0 */
/* global global, jest */
/**
 * @jest-environment jsdom
 */

import { Application } from "@hotwired/stimulus"
import MultipleMentionsController from "src/decidim/controllers/multiple_mentions/controller"

const AutoComplete = require("src/decidim/autocomplete");
const iconMock = require("src/decidim/icon");

// Mock the dependencies
jest.mock("src/decidim/autocomplete", () => {
  return jest.fn().mockImplementation(() => ({
    setInput: jest.fn()
  }));
});

jest.mock("src/decidim/icon", () => {
  return jest.fn().mockReturnValue("<svg>icon</svg>");
});

// Mock global fetch
global.fetch = jest.fn();

// Mock window.Decidim
global.window.Decidim = {
  config: {
    get: jest.fn((key) => {
      if (key === "messages") {
        return {
          mentionsModal: {
            removeRecipient: "Remove recipient %name%"
          }
        };
      }
      if (key === "api_path") {
        return "/api/graphql";
      }
      return null;
    })
  }
};

describe("MultipleMentionsManager", () => {
  let fieldContainer = null;
  let searchInput = null;
  let selectedItems = null;
  let application = null;
  let controller = null;

  beforeEach(() => {
    application = Application.start();
    application.register("multiple-mentions", MultipleMentionsController);

    // Reset all mocks
    jest.clearAllMocks();

    document.body.innerHTML = `<div>
    <div data-controller="multiple-mentions" class="form__wrapper gap-1 js-multiple-mentions" data-name="recipient_id[]" data-multiple="true">
      <label for="add_conversation_users">
        Participants
      </label>
      <span id="dialog-desc-conversation" class="help-text">Add users to conversation: 9 users max</span>
      <input id="add_conversation_users" type="text"
          spellcheck="false"
          autocomplete="off"
          placeholder="Search..."
          data-noresults="No results"
          data-selected= "selected-users"
          contenteditable="true"
          data-direct-messages-disabled="Direct messages disabled">
    </div>
    <ul class="selected-users"></ul>
  </div>`

    selectedItems = document.querySelector(".selected-users");
    searchInput = document.querySelector("[data-controller='multiple-mentions'] input");
    fieldContainer = document.querySelector("[data-controller='multiple-mentions']");

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(fieldContainer, "multiple-mentions");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    document.body.innerHTML = "";
  });

  describe("constructor", () => {
    it("should initialize with correct properties", () => {
      expect(controller.element).toBe(fieldContainer);
      expect(controller.searchInput).toBe(searchInput);
      expect(controller.selectedItems).toBe(selectedItems);
      expect(controller.selected).toEqual([]);
      expect(controller.removeLabel).toBe("Remove recipient %name%");
    });

    it("should create empty focus element if it does not exist", () => {
      const emptyFocusElement = document.querySelector(".empty-list");
      expect(emptyFocusElement).not.toBeNull();
      expect(emptyFocusElement.tabIndex).toBe(-1);
      expect(controller.emptyFocusElement).toBe(emptyFocusElement);
    });

    it("should use existing empty focus element if it exists", () => {
      const existingElement = document.querySelector(".empty-list");
      fieldContainer.appendChild(existingElement);

      expect(controller.emptyFocusElement).toBe(existingElement);
    });

    it("should initialize AutoComplete with correct configuration", () => {
      expect(AutoComplete).toHaveBeenCalledWith(searchInput, {
        dataMatchKeys: ["name", "nickname"],
        dataSource: expect.any(Function),
        dataFilter: expect.any(Function),
        modifyResult: expect.any(Function)
      });
    });
  });

  describe("getInputDataAttribute", () => {
    it("should return correct data attribute value", () => {
      expect(controller.getInputDataAttribute("selected")).toBe("selected-users");
      expect(controller.getInputDataAttribute("directMessagesDisabled")).toBe("Direct messages disabled");
    });

    it("should return undefined for nonexistent attributes", () => {
      expect(controller.getInputDataAttribute("nonExistent")).toBeUndefined();
    });
  });

  describe("getElementData", () => {
    it("should return all data attributes as an object", () => {
      const data = controller.getElementData(fieldContainer);

      expect(data.name).toBe("recipient_id[]");
    });

    it("should return empty object for element with no data attributes", () => {
      const emptyElement = document.createElement("div");
      const data = controller.getElementData(emptyElement);

      expect(data).toEqual({});
    });
  });

  describe("getDataSource", () => {
    beforeEach(() => {
      global.fetch.mockClear();
    });

    it("should make API call with correct GraphQL query", async () => {
      const mockResponse = {
        json: jest.fn().mockResolvedValue({
          data: {
            users: [
              { id: "1", name: "John Doe", nickname: "john", avatarUrl: "avatar1.jpg" },
              { id: "2", name: "Jane Smith", nickname: "jane", avatarUrl: "avatar2.jpg" }
            ]
          }
        })
      };
      global.fetch.mockResolvedValue(mockResponse);

      const callback = jest.fn();

      await controller.getDataSource("test query", callback);

      expect(global.fetch).toHaveBeenCalledWith("/api/graphql", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: expect.stringContaining("test query")
      });

      expect(callback).toHaveBeenCalledWith([
        { id: "1", name: "John Doe", nickname: "john", avatarUrl: "avatar1.jpg" },
        { id: "2", name: "Jane Smith", nickname: "jane", avatarUrl: "avatar2.jpg" }
      ]);
    });

    it("should handle API errors gracefully", async () => {
      global.fetch.mockRejectedValue(new Error("API Error"));
      const consoleSpy = jest.spyOn(console, "error").mockImplementation(() => {});

      const callback = jest.fn();

      await controller.getDataSource("test query", callback);

      expect(consoleSpy).toHaveBeenCalledWith("Error fetching users:", expect.any(Error));
      expect(callback).toHaveBeenCalledWith([]);

      consoleSpy.mockRestore();
    });

    it("should handle malformed API response", async () => {
      const mockResponse = {
        json: jest.fn().mockResolvedValue({
          // Missing data.users
          errors: ["GraphQL error"]
        })
      };
      global.fetch.mockResolvedValue(mockResponse);
      const consoleSpy = jest.spyOn(console, "error").mockImplementation(() => {});

      const callback = jest.fn();

      await controller.getDataSource("test query", callback);

      expect(consoleSpy).toHaveBeenCalled();
      expect(callback).toHaveBeenCalledWith([]);

      consoleSpy.mockRestore();
    });
  });

  describe("filterResults", () => {
    it("should filter out already selected users", () => {
      controller.selected = ["1", "3"];

      const list = [
        { value: { id: "1" } },
        { value: { id: "2" } },
        { value: { id: "3" } },
        { value: { id: "4" } }
      ];

      const filtered = controller.filterResults(list);

      expect(filtered).toEqual([
        { value: { id: "2" } },
        { value: { id: "4" } }
      ]);
    });

    it("should return all users when none are selected", () => {
      const list = [
        { value: { id: "1" } },
        { value: { id: "2" } }
      ];

      const filtered = controller.filterResults(list);

      expect(filtered).toEqual(list);
    });

    it("should return empty array when all users are selected", () => {
      controller.selected = ["1", "2"];

      const list = [
        { value: { id: "1" } },
        { value: { id: "2" } }
      ];

      const filtered = controller.filterResults(list);

      expect(filtered).toEqual([]);
    });
  });

  describe("modifyResult", () => {
    it("should set correct HTML for enabled user", () => {
      const element = document.createElement("div");
      const value = {
        avatarUrl: "avatar.jpg",
        name: "John Doe",
        nickname: "john",
        directMessagesEnabled: "true"
      };

      controller.modifyResult(element, value);

      expect(element.innerHTML).toContain('<img src="avatar.jpg" alt="John Doe">');
      expect(element.innerHTML).toContain("<span>john</span>");
      expect(element.innerHTML).toContain("<small>John Doe</small>");
      expect(element.classList.contains("disabled")).toBe(false);
    });

    it("should add disabled class and message for disabled user", () => {
      const element = document.createElement("div");
      const value = {
        avatarUrl: "avatar.jpg",
        name: "John Doe",
        nickname: "john",
        directMessagesEnabled: "false"
      };

      controller.modifyResult(element, value);

      expect(element.classList.contains("disabled")).toBe(true);
      expect(element.textContent).toContain("Direct messages disabled");
    });

    it("should handle missing avatar URL gracefully", () => {
      const element = document.createElement("div");
      const value = {
        avatarUrl: "",
        name: "John Doe",
        nickname: "john",
        directMessagesEnabled: "true"
      };

      expect(() => {
        controller.modifyResult(element, value);
      }).not.toThrow();

      expect(element.innerHTML).toContain('<img src="" alt="John Doe">');
    });
  });

  describe("handleSelection", () => {
    it("should add user when selection is valid", () => {
      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg",
          directMessagesEnabled: "true"
        }
      };

      controller.handleSelection(selection);

      expect(controller.selected).toContain("1");
      expect(selectedItems.children.length).toBe(1);
      expect(controller.autoComplete.setInput).toHaveBeenCalledWith("");
    });

    it("should not add user when max limit is reached", () => {

      controller.selected = Array.from({ length: 9 }, (_, i) => `${i + 1}`);

      const selection = {
        value: {
          id: "10",
          name: "John Doe",
          avatarUrl: "avatar.jpg",
          directMessagesEnabled: "true"
        }
      };

      controller.handleSelection(selection);

      expect(controller.selected).not.toContain("10");
      expect(selectedItems.children.length).toBe(0);
      expect(controller.autoComplete.setInput).not.toHaveBeenCalled();
    });

    it("should not add user when direct messages are disabled", () => {

      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg",
          directMessagesEnabled: "false"
        }
      };

      controller.handleSelection(selection);

      expect(controller.selected).not.toContain("1");
      expect(selectedItems.children.length).toBe(0);
      expect(controller.autoComplete.setInput).not.toHaveBeenCalled();
    });

    it("should handle multiple valid selections", () => {


      const selections = [
        { value: { id: "1", name: "John Doe", avatarUrl: "avatar1.jpg", directMessagesEnabled: "true" } },
        { value: { id: "2", name: "Jane Smith", avatarUrl: "avatar2.jpg", directMessagesEnabled: "true" } }
      ];

      selections.forEach((selection) => controller.handleSelection(selection));

      expect(controller.selected).toEqual(["1", "2"]);
      expect(selectedItems.children.length).toBe(2);
      expect(controller.autoComplete.setInput).toHaveBeenCalledTimes(2);
    });
  });

  describe("addSelectedUser", () => {
    it("should create list item with correct content", () => {

      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg"
        }
      };

      controller.addSelectedUser(selection, "1");

      const listItem = selectedItems.firstChild;
      expect(listItem.tagName).toBe("LI");
      expect(listItem.tabIndex).toBe(-1);

      const hiddenInput = listItem.querySelector("input[type='hidden']");
      expect(hiddenInput.name).toBe("recipient_id[]");
      expect(hiddenInput.value).toBe("1");

      const removeButton = listItem.querySelector("[data-remove='1']");
      expect(removeButton).not.toBeNull();
      expect(removeButton.getAttribute("aria-label")).toBe("Remove recipient John Doe");
    });

    it("should attach event listeners to remove button", () => {

      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg"
        }
      };

      const addEventListenerSpy = jest.spyOn(Element.prototype, "addEventListener");

      controller.addSelectedUser(selection, "1");

      expect(addEventListenerSpy).toHaveBeenCalledWith("keypress", expect.any(Function));
      expect(addEventListenerSpy).toHaveBeenCalledWith("click", expect.any(Function));

      addEventListenerSpy.mockRestore();
    });

    it("should include icon in remove button", () => {
      iconMock.mockReturnValue("<svg data-testid='remove-icon'>icon</svg>");


      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg"
        }
      };

      controller.addSelectedUser(selection, "1");

      const listItem = selectedItems.firstChild;
      expect(listItem.innerHTML).toContain('data-testid="remove-icon"');
      expect(iconMock).toHaveBeenCalledWith("delete-bin-line");
    });
  });

  describe("handleRemoval", () => {
    it("should remove user and update state", () => {

      controller.selected = ["1"];

      // Create a list item
      const listItem = document.createElement("li");
      const removeButton = document.createElement("button");
      removeButton.dataset.remove = "1";
      listItem.appendChild(removeButton);
      selectedItems.appendChild(listItem);

      const mockEvent = {
        currentTarget: removeButton
      };

      // Mock focus method
      controller.emptyFocusElement.focus = jest.fn();

      controller.handleRemoval(mockEvent, "1");

      expect(controller.selected).not.toContain("1");
      expect(selectedItems.children.length).toBe(0);
      expect(controller.emptyFocusElement.focus).toHaveBeenCalled();
    });

    it("should focus on next sibling when available", () => {

      controller.selected = ["1", "2"];

      // Create multiple list items
      const listItem1 = document.createElement("li");
      const removeButton1 = document.createElement("button");
      removeButton1.dataset.remove = "1";
      listItem1.appendChild(removeButton1);

      const listItem2 = document.createElement("li");
      listItem2.focus = jest.fn();

      selectedItems.appendChild(listItem1);
      selectedItems.appendChild(listItem2);

      const mockEvent = {
        currentTarget: removeButton1
      };

      controller.handleRemoval(mockEvent, "1");

      expect(listItem2.focus).toHaveBeenCalled();
    });

    it("should focus on previous sibling when next is not available", () => {

      controller.selected = ["1", "2"];

      // Create multiple list items
      const listItem1 = document.createElement("li");
      listItem1.focus = jest.fn();

      const listItem2 = document.createElement("li");
      const removeButton2 = document.createElement("button");
      removeButton2.dataset.remove = "2";
      listItem2.appendChild(removeButton2);

      selectedItems.appendChild(listItem1);
      selectedItems.appendChild(listItem2);

      const mockEvent = {
        currentTarget: removeButton2
      };

      controller.handleRemoval(mockEvent, "2");

      expect(listItem1.focus).toHaveBeenCalled();
    });
  });

  describe("utility methods", () => {
    it("should return selected IDs", () => {

      controller.selected = ["1", "2", "3"];

      const selectedIds = controller.selected;

      expect(selectedIds).toEqual(["1", "2", "3"]);
      // Should return a copy
      expect(selectedIds).not.toBe(...controller.selected);
    });

    it("should clear all selections", () => {
      controller.selected = ["1", "2"];
      selectedItems.innerHTML = "<li>item1</li><li>item2</li>";

      controller.clearSelection();

      expect(controller.selected).toEqual([]);
      expect(selectedItems.innerHTML).toBe("");
    });
  });

  describe("integration scenarios", () => {
    it("should handle complete user selection and removal workflow", () => {
      // Add users
      const users = [
        { value: { id: "1", name: "John Doe", avatarUrl: "avatar1.jpg", directMessagesEnabled: "true" } },
        { value: { id: "2", name: "Jane Smith", avatarUrl: "avatar2.jpg", directMessagesEnabled: "true" } }
      ];

      users.forEach((user) => controller.handleSelection(user));

      expect(controller.selected).toEqual(["1", "2"]);
      expect(selectedItems.children.length).toBe(2);

      // Remove first user
      const firstRemoveButton = selectedItems.firstChild.querySelector("[data-remove='1']");
      const mockEvent = { currentTarget: firstRemoveButton };
      controller.handleRemoval(mockEvent, "1");

      expect(controller.selected).toEqual(["2"]);
      expect(selectedItems.children.length).toBe(1);

      // Remove last user
      const lastRemoveButton = selectedItems.firstChild.querySelector("[data-remove='2']");
      const mockEvent2 = { currentTarget: lastRemoveButton };
      controller.handleRemoval(mockEvent2, "2");

      expect(controller.selected).toEqual([]);
      expect(selectedItems.children.length).toBe(0);
    });

    it("should handle edge case with maximum user selections", () => {
      // Add 9 users (maximum)
      for (let i = 1; i <= 9; i += 1) {
        const user = {
          value: {
            id: `${i}`,
            name: `User ${i}`,
            avatarUrl: `avatar${i}.jpg`,
            directMessagesEnabled: "true"
          }
        };
        controller.handleSelection(user);
      }

      expect(controller.selected.length).toBe(9);

      // Try to add 10th user (should be rejected)
      const tenthUser = {
        value: {
          id: "10",
          name: "User 10",
          avatarUrl: "avatar10.jpg",
          directMessagesEnabled: "true"
        }
      };
      controller.handleSelection(tenthUser);

      expect(controller.selected.length).toBe(9);
      expect(controller.selected).not.toContain("10");
    });

    it("should maintain correct state after mixed operations", () => {
      // Add some users
      const users = [
        { value: { id: "1", name: "John", avatarUrl: "avatar1.jpg", directMessagesEnabled: "true" } },
        { value: { id: "2", name: "Jane", avatarUrl: "avatar2.jpg", directMessagesEnabled: "false" } },
        { value: { id: "3", name: "Bob", avatarUrl: "avatar3.jpg", directMessagesEnabled: "true" } }
      ];

      users.forEach((user) => controller.handleSelection(user));

      // Only users 1 and 3 should be added (user 2 has disabled direct messages)
      expect(controller.selected).toEqual(["1", "3"]);
      expect(selectedItems.children.length).toBe(2);

      // Clear all selections
      controller.clearSelection();

      expect(controller.selected).toEqual([]);
      expect(selectedItems.children.length).toBe(0);

      // Add users again
      controller.handleSelection(users[0]);
      controller.handleSelection(users[2]);

      expect(controller.selected).toEqual(["1", "3"]);
      expect(selectedItems.children.length).toBe(2);
    });
  });
});
