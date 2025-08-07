/* eslint max-lines: ["error", 775] , id-length: 0 */
/* global global, jest */
/**
 * @jest-environment jsdom
 */

import MultipleMentionsManager from "src/decidim/refactor/implementation/input_multiple_mentions";

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
  let container = null;
  let fieldContainer = null;
  let searchInput = null;
  let selectedItems = null;
  let form = null;
  let submitButton = null;

  beforeEach(() => {
    // Reset all mocks
    jest.clearAllMocks();

    // Create DOM structure
    document.body.innerHTML = "";
    container = document.createElement("div");

    form = document.createElement("form");
    submitButton = document.createElement("button");
    submitButton.type = "submit";
    form.appendChild(submitButton);

    fieldContainer = document.createElement("div");
    fieldContainer.className = "js-multiple-mentions";
    fieldContainer.dataset.name = "user_ids[]";

    searchInput = document.createElement("input");
    searchInput.dataset.selected = "selected-users";
    searchInput.dataset.directMessagesDisabled = "Direct messages disabled";

    selectedItems = document.createElement("ul");
    selectedItems.className = "selected-users";

    fieldContainer.appendChild(searchInput);
    fieldContainer.appendChild(selectedItems);
    form.appendChild(fieldContainer);
    container.appendChild(form);
    document.body.appendChild(container);
  });

  afterEach(() => {
    document.body.innerHTML = "";
  });

  describe("constructor", () => {
    it("should initialize with correct properties", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      expect(manager.fieldContainer).toBe(fieldContainer);
      expect(manager.searchInput).toBe(searchInput);
      expect(manager.selectedItems).toBe(selectedItems);
      expect(manager.selected).toEqual([]);
      expect(manager.removeLabel).toBe("Remove recipient %name%");
    });

    it("should create empty focus element if it does not exist", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      const emptyFocusElement = fieldContainer.parentNode.querySelector(".empty-list");
      expect(emptyFocusElement).not.toBeNull();
      expect(emptyFocusElement.tabIndex).toBe(-1);
      expect(manager.emptyFocusElement).toBe(emptyFocusElement);
    });

    it("should use existing empty focus element if it exists", () => {
      const existingElement = document.createElement("div");
      existingElement.className = "empty-list";
      fieldContainer.appendChild(existingElement);

      const manager = new MultipleMentionsManager(fieldContainer);

      expect(manager.emptyFocusElement).toBe(existingElement);
    });

    it("should initialize AutoComplete with correct configuration", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      expect(AutoComplete).toHaveBeenCalledWith(searchInput, {
        dataMatchKeys: ["name", "nickname"],
        dataSource: expect.any(Function),
        dataFilter: expect.any(Function),
        modifyResult: expect.any(Function)
      });
      expect(manager).toBeInstanceOf(MultipleMentionsManager);
    });

    it("should set submit button to disabled initially when no items selected", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      expect(submitButton.disabled).toBe(true);
      expect(manager).toBeInstanceOf(MultipleMentionsManager);
    });
  });

  describe("getInputDataAttribute", () => {
    it("should return correct data attribute value", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      expect(manager.getInputDataAttribute("selected")).toBe("selected-users");
      expect(manager.getInputDataAttribute("directMessagesDisabled")).toBe("Direct messages disabled");
    });

    it("should return undefined for nonexistent attributes", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      expect(manager.getInputDataAttribute("nonExistent")).toBeUndefined();
    });
  });

  describe("getElementData", () => {
    it("should return all data attributes as an object", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      const data = manager.getElementData(fieldContainer);

      expect(data.name).toBe("user_ids[]");
    });

    it("should return empty object for element with no data attributes", () => {
      const emptyElement = document.createElement("div");
      const manager = new MultipleMentionsManager(fieldContainer);
      const data = manager.getElementData(emptyElement);

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

      const manager = new MultipleMentionsManager(fieldContainer);
      const callback = jest.fn();

      await manager.getDataSource("test query", callback);

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

      const manager = new MultipleMentionsManager(fieldContainer);
      const callback = jest.fn();

      await manager.getDataSource("test query", callback);

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

      const manager = new MultipleMentionsManager(fieldContainer);
      const callback = jest.fn();

      await manager.getDataSource("test query", callback);

      expect(consoleSpy).toHaveBeenCalled();
      expect(callback).toHaveBeenCalledWith([]);

      consoleSpy.mockRestore();
    });
  });

  describe("filterResults", () => {
    it("should filter out already selected users", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      manager.selected = ["1", "3"];

      const list = [
        { value: { id: "1" } },
        { value: { id: "2" } },
        { value: { id: "3" } },
        { value: { id: "4" } }
      ];

      const filtered = manager.filterResults(list);

      expect(filtered).toEqual([
        { value: { id: "2" } },
        { value: { id: "4" } }
      ]);
    });

    it("should return all users when none are selected", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      const list = [
        { value: { id: "1" } },
        { value: { id: "2" } }
      ];

      const filtered = manager.filterResults(list);

      expect(filtered).toEqual(list);
    });

    it("should return empty array when all users are selected", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      manager.selected = ["1", "2"];

      const list = [
        { value: { id: "1" } },
        { value: { id: "2" } }
      ];

      const filtered = manager.filterResults(list);

      expect(filtered).toEqual([]);
    });
  });

  describe("modifyResult", () => {
    it("should set correct HTML for enabled user", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      const element = document.createElement("div");
      const value = {
        avatarUrl: "avatar.jpg",
        name: "John Doe",
        nickname: "john",
        directMessagesEnabled: "true"
      };

      manager.modifyResult(element, value);

      expect(element.innerHTML).toContain('<img src="avatar.jpg" alt="John Doe">');
      expect(element.innerHTML).toContain("<span>john</span>");
      expect(element.innerHTML).toContain("<small>John Doe</small>");
      expect(element.classList.contains("disabled")).toBe(false);
    });

    it("should add disabled class and message for disabled user", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      const element = document.createElement("div");
      const value = {
        avatarUrl: "avatar.jpg",
        name: "John Doe",
        nickname: "john",
        directMessagesEnabled: "false"
      };

      manager.modifyResult(element, value);

      expect(element.classList.contains("disabled")).toBe(true);
      expect(element.textContent).toContain("Direct messages disabled");
    });

    it("should handle missing avatar URL gracefully", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      const element = document.createElement("div");
      const value = {
        avatarUrl: "",
        name: "John Doe",
        nickname: "john",
        directMessagesEnabled: "true"
      };

      expect(() => {
        manager.modifyResult(element, value);
      }).not.toThrow();

      expect(element.innerHTML).toContain('<img src="" alt="John Doe">');
    });
  });

  describe("handleSelection", () => {
    it("should add user when selection is valid", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg",
          directMessagesEnabled: "true"
        }
      };

      manager.handleSelection(selection);

      expect(manager.selected).toContain("1");
      expect(selectedItems.children.length).toBe(1);
      expect(manager.autoComplete.setInput).toHaveBeenCalledWith("");
      expect(submitButton.disabled).toBe(false);
    });

    it("should not add user when max limit is reached", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      manager.selected = Array.from({ length: 9 }, (_, i) => `${i + 1}`);

      const selection = {
        value: {
          id: "10",
          name: "John Doe",
          avatarUrl: "avatar.jpg",
          directMessagesEnabled: "true"
        }
      };

      manager.handleSelection(selection);

      expect(manager.selected).not.toContain("10");
      expect(selectedItems.children.length).toBe(0);
      expect(manager.autoComplete.setInput).not.toHaveBeenCalled();
    });

    it("should not add user when direct messages are disabled", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg",
          directMessagesEnabled: "false"
        }
      };

      manager.handleSelection(selection);

      expect(manager.selected).not.toContain("1");
      expect(selectedItems.children.length).toBe(0);
      expect(manager.autoComplete.setInput).not.toHaveBeenCalled();
    });

    it("should handle multiple valid selections", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      const selections = [
        { value: { id: "1", name: "John Doe", avatarUrl: "avatar1.jpg", directMessagesEnabled: "true" } },
        { value: { id: "2", name: "Jane Smith", avatarUrl: "avatar2.jpg", directMessagesEnabled: "true" } }
      ];

      selections.forEach((selection) => manager.handleSelection(selection));

      expect(manager.selected).toEqual(["1", "2"]);
      expect(selectedItems.children.length).toBe(2);
      expect(manager.autoComplete.setInput).toHaveBeenCalledTimes(2);
    });
  });

  describe("addSelectedUser", () => {
    it("should create list item with correct content", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg"
        }
      };

      manager.addSelectedUser(selection, "1");

      const listItem = selectedItems.firstChild;
      expect(listItem.tagName).toBe("LI");
      expect(listItem.tabIndex).toBe(-1);

      const hiddenInput = listItem.querySelector("input[type='hidden']");
      expect(hiddenInput.name).toBe("user_ids[]");
      expect(hiddenInput.value).toBe("1");

      const removeButton = listItem.querySelector("[data-remove='1']");
      expect(removeButton).not.toBeNull();
      expect(removeButton.getAttribute("aria-label")).toBe("Remove recipient John Doe");
    });

    it("should attach event listeners to remove button", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg"
        }
      };

      const addEventListenerSpy = jest.spyOn(Element.prototype, "addEventListener");

      manager.addSelectedUser(selection, "1");

      expect(addEventListenerSpy).toHaveBeenCalledWith("keypress", expect.any(Function));
      expect(addEventListenerSpy).toHaveBeenCalledWith("click", expect.any(Function));

      addEventListenerSpy.mockRestore();
    });

    it("should include icon in remove button", () => {
      iconMock.mockReturnValue("<svg data-testid='remove-icon'>icon</svg>");

      const manager = new MultipleMentionsManager(fieldContainer);
      const selection = {
        value: {
          id: "1",
          name: "John Doe",
          avatarUrl: "avatar.jpg"
        }
      };

      manager.addSelectedUser(selection, "1");

      const listItem = selectedItems.firstChild;
      expect(listItem.innerHTML).toContain('data-testid="remove-icon"');
      expect(iconMock).toHaveBeenCalledWith("delete-bin-line");
    });
  });

  describe("handleRemoval", () => {
    it("should remove user and update state", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      manager.selected = ["1"];

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
      manager.emptyFocusElement.focus = jest.fn();

      manager.handleRemoval(mockEvent, "1");

      expect(manager.selected).not.toContain("1");
      expect(selectedItems.children.length).toBe(0);
      expect(manager.emptyFocusElement.focus).toHaveBeenCalled();
      expect(submitButton.disabled).toBe(true);
    });

    it("should focus on next sibling when available", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      manager.selected = ["1", "2"];

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

      manager.handleRemoval(mockEvent, "1");

      expect(listItem2.focus).toHaveBeenCalled();
    });

    it("should focus on previous sibling when next is not available", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      manager.selected = ["1", "2"];

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

      manager.handleRemoval(mockEvent, "2");

      expect(listItem1.focus).toHaveBeenCalled();
    });
  });

  describe("updateSubmitButton", () => {
    it("should disable submit button when no items are selected", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      manager.updateSubmitButton();

      expect(submitButton.disabled).toBe(true);
    });

    it("should enable submit button when items are selected", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      const listItem = document.createElement("li");
      selectedItems.appendChild(listItem);

      manager.updateSubmitButton();

      expect(submitButton.disabled).toBe(false);
    });

    it("should handle case when form is not found", () => {
      const isolatedContainer = document.createElement("div");
      const isolatedInput = document.createElement("input");
      isolatedInput.dataset.selected = "selected-users";
      const isolatedItems = document.createElement("ul");
      isolatedItems.className = "selected-users";
      isolatedContainer.appendChild(isolatedInput);
      isolatedContainer.appendChild(isolatedItems);
      document.body.appendChild(isolatedContainer);

      expect(() => {
        const manager = new MultipleMentionsManager(isolatedContainer);
        manager.updateSubmitButton();
      }).not.toThrow();
    });

    it("should handle case when submit button is not found", () => {
      const formWithoutButton = document.createElement("form");
      const containerInForm = document.createElement("div");
      const inputInForm = document.createElement("input");
      inputInForm.dataset.selected = "selected-users";
      const itemsInForm = document.createElement("ul");
      itemsInForm.className = "selected-users";

      containerInForm.appendChild(inputInForm);
      containerInForm.appendChild(itemsInForm);
      formWithoutButton.appendChild(containerInForm);
      document.body.appendChild(formWithoutButton);

      expect(() => {
        const manager = new MultipleMentionsManager(containerInForm);
        manager.updateSubmitButton();
      }).not.toThrow();
    });
  });

  describe("utility methods", () => {
    it("should return selected IDs", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      manager.selected = ["1", "2", "3"];

      const selectedIds = manager.getSelectedIds();

      expect(selectedIds).toEqual(["1", "2", "3"]);
      // Should return a copy
      expect(selectedIds).not.toBe(manager.selected);
    });

    it("should clear all selections", () => {
      const manager = new MultipleMentionsManager(fieldContainer);
      manager.selected = ["1", "2"];
      selectedItems.innerHTML = "<li>item1</li><li>item2</li>";

      manager.clearSelection();

      expect(manager.selected).toEqual([]);
      expect(selectedItems.innerHTML).toBe("");
      expect(submitButton.disabled).toBe(true);
    });

    it("should check if max limit is reached", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      expect(manager.isMaxLimitReached()).toBe(false);

      manager.selected = Array.from({ length: 8 }, (_, i) => `${i + 1}`);
      expect(manager.isMaxLimitReached()).toBe(false);

      manager.selected = Array.from({ length: 9 }, (_, i) => `${i + 1}`);
      expect(manager.isMaxLimitReached()).toBe(true);

      manager.selected = Array.from({ length: 10 }, (_, i) => `${i + 1}`);
      expect(manager.isMaxLimitReached()).toBe(true);
    });
  });

  describe("integration scenarios", () => {
    it("should handle complete user selection and removal workflow", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      // Add users
      const users = [
        { value: { id: "1", name: "John Doe", avatarUrl: "avatar1.jpg", directMessagesEnabled: "true" } },
        { value: { id: "2", name: "Jane Smith", avatarUrl: "avatar2.jpg", directMessagesEnabled: "true" } }
      ];

      users.forEach((user) => manager.handleSelection(user));

      expect(manager.selected).toEqual(["1", "2"]);
      expect(selectedItems.children.length).toBe(2);
      expect(submitButton.disabled).toBe(false);

      // Remove first user
      const firstRemoveButton = selectedItems.firstChild.querySelector("[data-remove='1']");
      const mockEvent = { currentTarget: firstRemoveButton };
      manager.handleRemoval(mockEvent, "1");

      expect(manager.selected).toEqual(["2"]);
      expect(selectedItems.children.length).toBe(1);
      expect(submitButton.disabled).toBe(false);

      // Remove last user
      const lastRemoveButton = selectedItems.firstChild.querySelector("[data-remove='2']");
      const mockEvent2 = { currentTarget: lastRemoveButton };
      manager.handleRemoval(mockEvent2, "2");

      expect(manager.selected).toEqual([]);
      expect(selectedItems.children.length).toBe(0);
      expect(submitButton.disabled).toBe(true);
    });

    it("should handle edge case with maximum user selections", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

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
        manager.handleSelection(user);
      }

      expect(manager.selected.length).toBe(9);
      expect(manager.isMaxLimitReached()).toBe(true);

      // Try to add 10th user (should be rejected)
      const tenthUser = {
        value: {
          id: "10",
          name: "User 10",
          avatarUrl: "avatar10.jpg",
          directMessagesEnabled: "true"
        }
      };
      manager.handleSelection(tenthUser);

      expect(manager.selected.length).toBe(9);
      expect(manager.selected).not.toContain("10");
    });

    it("should maintain correct state after mixed operations", () => {
      const manager = new MultipleMentionsManager(fieldContainer);

      // Add some users
      const users = [
        { value: { id: "1", name: "John", avatarUrl: "avatar1.jpg", directMessagesEnabled: "true" } },
        { value: { id: "2", name: "Jane", avatarUrl: "avatar2.jpg", directMessagesEnabled: "false" } },
        { value: { id: "3", name: "Bob", avatarUrl: "avatar3.jpg", directMessagesEnabled: "true" } }
      ];

      users.forEach((user) => manager.handleSelection(user));

      // Only users 1 and 3 should be added (user 2 has disabled direct messages)
      expect(manager.selected).toEqual(["1", "3"]);
      expect(selectedItems.children.length).toBe(2);

      // Clear all selections
      manager.clearSelection();

      expect(manager.selected).toEqual([]);
      expect(selectedItems.children.length).toBe(0);
      expect(submitButton.disabled).toBe(true);

      // Add users again
      manager.handleSelection(users[0]);
      manager.handleSelection(users[2]);

      expect(manager.selected).toEqual(["1", "3"]);
      expect(selectedItems.children.length).toBe(2);
      expect(submitButton.disabled).toBe(false);
    });
  });
});
