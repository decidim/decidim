/* eslint max-lines: ["error", 350] */
/* global global, jest */

import ClipboardCopy from "src/decidim/refactor/implementation/copy_clipboard";
const select = require("select");

// Mock the select function
jest.mock("select", () => jest.fn());

describe("ClipboardCopy", () => {
  let mockElement = null;
  let mockTargetElement = null;
  let clipboardCopy = null;

  beforeEach(() => {
    // Reset DOM
    document.body.innerHTML = "";

    // Mock document.execCommand
    document.execCommand = jest.fn().mockReturnValue(true);

    // Create mock elements
    mockElement = document.createElement("button");
    mockElement.dataset.clipboardCopy = "#target-input";
    mockElement.dataset.clipboardCopyLabel = "Copied!";
    mockElement.dataset.clipboardCopyMessage = "Text copied to clipboard";
    mockElement.textContent = "Copy to clipboard";

    mockTargetElement = document.createElement("input");
    mockTargetElement.id = "target-input";
    mockTargetElement.value = "Test content";

    document.body.appendChild(mockElement);
    document.body.appendChild(mockTargetElement);

    // Clear all timers
    jest.clearAllTimers();
    jest.useFakeTimers();
  });

  afterEach(() => {
    if (clipboardCopy) {
      clipboardCopy.destroy();
    }
    jest.useRealTimers();
    jest.restoreAllMocks();
  });

  describe("constructor", () => {
    it("should throw error if no element is provided", () => {
      expect(() => new ClipboardCopy()).toThrow("ClipboardCopy requires a DOM element");
    });

    it("should initialize with correct properties", () => {
      clipboardCopy = new ClipboardCopy(mockElement);

      expect(clipboardCopy.element).toBe(mockElement);
      expect(clipboardCopy.targetSelector).toBe("#target-input");
      expect(clipboardCopy.copyLabel).toBe("Copied!");
      expect(clipboardCopy.copyMessage).toBe("Text copied to clipboard");
    });

    it("should bind click event listener", () => {
      const addEventListenerSpy = jest.spyOn(mockElement, "addEventListener");
      clipboardCopy = new ClipboardCopy(mockElement);

      expect(addEventListenerSpy).toHaveBeenCalledWith("click", expect.any(Function));
    });
  });

  describe("_handleClick", () => {
    beforeEach(() => {
      clipboardCopy = new ClipboardCopy(mockElement);
    });

    it("should prevent default event behavior", () => {
      const mockEvent = { preventDefault: jest.fn() };
      clipboardCopy._handleClick(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
    });

    it("should return early if no target selector", () => {
      mockElement.dataset.clipboardCopy = "";
      clipboardCopy = new ClipboardCopy(mockElement);

      clipboardCopy._handleClick({ preventDefault: jest.fn() });
      expect(document.execCommand).not.toHaveBeenCalled();
    });

    it("should return early if target element not found", () => {
      mockElement.dataset.clipboardCopy = "#non-existent";
      clipboardCopy = new ClipboardCopy(mockElement);

      clipboardCopy._handleClick({ preventDefault: jest.fn() });
      expect(document.execCommand).not.toHaveBeenCalled();
    });

    it("should copy text successfully", () => {
      select.mockReturnValue("Test content");

      clipboardCopy._handleClick({ preventDefault: jest.fn() });

      expect(document.execCommand).toHaveBeenCalledWith("copy");
    });
  });

  describe("_getTextToCopy", () => {
    beforeEach(() => {
      clipboardCopy = new ClipboardCopy(mockElement);
    });

    it("should return custom content if provided", () => {
      mockElement.dataset.clipboardContent = "Custom content";
      clipboardCopy = new ClipboardCopy(mockElement);

      const result = clipboardCopy._getTextToCopy(mockTargetElement);
      expect(result).toBe("Custom content");
    });

    it("should use select function for input elements", () => {
      select.mockReturnValue("Selected content");

      const result = clipboardCopy._getTextToCopy(mockTargetElement);

      expect(select).toHaveBeenCalledWith(mockTargetElement);
      expect(result).toBe("Selected content");
    });

    it("should return empty string for non-input elements without custom content", () => {
      const divElement = document.createElement("div");
      divElement.textContent = "Some text";

      const result = clipboardCopy._getTextToCopy(divElement);
      expect(result).toBe("");
    });
  });

  describe("_isInputElement", () => {
    beforeEach(() => {
      clipboardCopy = new ClipboardCopy(mockElement);
    });

    it("should return true for input elements", () => {
      expect(clipboardCopy._isInputElement(mockTargetElement)).toBe(true);
    });

    it("should return true for textarea elements", () => {
      const textarea = document.createElement("textarea");
      expect(clipboardCopy._isInputElement(textarea)).toBe(true);
    });

    it("should return true for select elements", () => {
      const selectBox = document.createElement("select");
      expect(clipboardCopy._isInputElement(selectBox)).toBe(true);
    });

    it("should return false for other elements", () => {
      const div = document.createElement("div");
      expect(clipboardCopy._isInputElement(div)).toBe(false);
    });
  });

  describe("_copyToClipboard", () => {
    beforeEach(() => {
      clipboardCopy = new ClipboardCopy(mockElement);
    });

    it("should create temporary textarea and copy text", () => {
      const result = clipboardCopy._copyToClipboard("Test text");

      expect(document.execCommand).toHaveBeenCalledWith("copy");
      expect(result).toBe(true);
    });

    it("should handle copy failure gracefully", () => {
      document.execCommand.mockImplementation(() => {
        throw new Error("Copy failed");
      });

      const result = clipboardCopy._copyToClipboard("Test text");
      expect(result).toBe(false);
    });

    it("should focus back to button after copy", () => {
      const focusSpy = jest.spyOn(mockElement, "focus");
      clipboardCopy._copyToClipboard("Test text");

      expect(focusSpy).toHaveBeenCalled();
    });
  });

  describe("_showSuccessMessage", () => {
    beforeEach(() => {
      clipboardCopy = new ClipboardCopy(mockElement);
    });

    it("should show success label and reset after timeout", () => {
      clipboardCopy._showSuccessMessage(mockTargetElement);

      expect(mockElement.innerHTML).toBe("Copied!");

      jest.advanceTimersByTime(ClipboardCopy.CLIPBOARD_COPY_TIMEOUT);

      expect(mockElement.innerHTML).toBe("Copy to clipboard");
    });

    it("should clear existing timeout before setting new one", () => {
      const clearTimeoutSpy = jest.spyOn(global, "clearTimeout");

      clipboardCopy._showSuccessMessage(mockTargetElement);
      clipboardCopy._showSuccessMessage(mockTargetElement);

      expect(clearTimeoutSpy).toHaveBeenCalled();
    });

    it("should return early if no copy label", () => {
      mockElement.dataset.clipboardCopyLabel = "";
      clipboardCopy = new ClipboardCopy(mockElement);

      const originalContent = mockElement.innerHTML;
      clipboardCopy._showSuccessMessage(mockTargetElement);

      expect(mockElement.innerHTML).toBe(originalContent);
    });
  });

  describe("_announceToScreenReader", () => {
    beforeEach(() => {
      clipboardCopy = new ClipboardCopy(mockElement);
    });

    it("should create and append screen reader message element", () => {
      clipboardCopy._announceToScreenReader();

      const messageEl = mockElement.querySelector('[role="alert"]');
      expect(messageEl).toBeTruthy();
      expect(messageEl.getAttribute("aria-live")).toBe("assertive");
      expect(messageEl.getAttribute("aria-atomic")).toBe("true");
      expect(messageEl.className).toBe("sr-only");
    });

    it("should add non-breaking space to force re-announcement", () => {
      clipboardCopy._announceToScreenReader();
      clipboardCopy._announceToScreenReader();

      const messageEl = mockElement.querySelector('[role="alert"]');
      expect(messageEl.innerHTML).toContain("&nbsp;");
    });

    it("should return early if no copy message", () => {
      mockElement.dataset.clipboardCopyMessage = "";
      clipboardCopy = new ClipboardCopy(mockElement);

      clipboardCopy._announceToScreenReader();

      const messageEl = mockElement.querySelector('[role="alert"]');
      expect(messageEl).toBeFalsy();
    });
  });

  describe("destroy", () => {
    beforeEach(() => {
      clipboardCopy = new ClipboardCopy(mockElement);
    });

    it("should clear timeout and remove message element", () => {
      const clearTimeoutSpy = jest.spyOn(global, "clearTimeout");

      clipboardCopy._showSuccessMessage(mockTargetElement);
      clipboardCopy._announceToScreenReader();

      const messageEl = mockElement.querySelector('[role="alert"]');
      expect(messageEl).toBeTruthy();

      clipboardCopy.destroy();

      expect(clearTimeoutSpy).toHaveBeenCalled();
      expect(mockElement.querySelector('[role="alert"]')).toBeFalsy();
    });

    it("should remove event listener", () => {
      const removeEventListenerSpy = jest.spyOn(mockElement, "removeEventListener");

      clipboardCopy.destroy();

      expect(removeEventListenerSpy).toHaveBeenCalledWith("click", expect.any(Function));
    });
  });

  describe("static initializeAll", () => {
    it("should initialize ClipboardCopy for all elements with data-clipboard-copy", () => {
      const button1 = document.createElement("button");
      button1.dataset.clipboardCopy = "#input1";
      const button2 = document.createElement("button");
      button2.dataset.clipboardCopy = "#input2";

      document.body.appendChild(button1);
      document.body.appendChild(button2);

      ClipboardCopy.initializeAll();

      expect(button1._clipboardCopy).toBeInstanceOf(ClipboardCopy);
      expect(button2._clipboardCopy).toBeInstanceOf(ClipboardCopy);
    });

    it("should not reinitialize already initialized elements", () => {
      const button = document.createElement("button");
      button.dataset.clipboardCopy = "#input1";
      document.body.appendChild(button);

      ClipboardCopy.initializeAll();
      const firstInstance = button._clipboardCopy;

      ClipboardCopy.initializeAll();
      const secondInstance = button._clipboardCopy;

      expect(firstInstance).toBe(secondInstance);
    });
  });

  describe("integration tests", () => {
    it("should handle complete copy workflow", () => {
      select.mockReturnValue("Test content");

      clipboardCopy = new ClipboardCopy(mockElement);

      // Simulate click
      const clickEvent = new Event("click");
      mockElement.dispatchEvent(clickEvent);

      // Verify copy was attempted
      expect(document.execCommand).toHaveBeenCalledWith("copy");

      // Verify success message is shown
      expect(mockElement.innerHTML).toBe('Copied!<div role="alert" aria-live="assertive" aria-atomic="true" class="sr-only">Text copied to clipboard</div>');

      // Verify screen reader message is added
      const messageEl = mockElement.querySelector('[role="alert"]');
      expect(messageEl.innerHTML).toBe("Text copied to clipboard");

      // Fast forward time and verify reset
      jest.advanceTimersByTime(ClipboardCopy.CLIPBOARD_COPY_TIMEOUT);
      expect(mockElement.innerHTML).toBe("Copy to clipboard");
    });
  });
});
