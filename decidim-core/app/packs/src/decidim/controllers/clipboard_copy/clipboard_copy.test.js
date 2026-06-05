/* eslint max-lines: ["error", 370] */
/* global global, jest */
import { Application } from "@hotwired/stimulus"
import ClipboardCopyController from "src/decidim/controllers/clipboard_copy/controller";

const select = require("select");

jest.mock("select", () => jest.fn());

describe("ClipboardCopy", () => {
  let container = null;
  let copyElement = null;
  let copyTargetElement = null;
  let application = null;
  let controller = null;

  beforeEach(() => {
    application = Application.start();
    application.register("clipboard-copy", ClipboardCopyController);

    container = document.createElement("div");
    container.innerHTML = `
      <input id="urlCalendarUrl" type="text" title="Calendar URL" value="http://localhost:3000/s/YFCs0VqRjk" readonly>
      <button
        data-controller="clipboard-copy"
        data-clipboard-copy="#urlCalendarUrl"
        data-clipboard-copy-label="Copied!"
        data-clipboard-copy-message="Text copied to clipboard"
        aria-label="Copy calendar URL to clipboard">
        <svg width="1em" height="1em" role="img" aria-hidden="true" class="w-5 h-6 text-secondary fill-current"><use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-file-copy-line"></use></svg>
        <span class="sr-only">Copy</span>
      </button>`;

    // Mock document.execCommand
    document.execCommand = jest.fn().mockReturnValue(true);

    document.body.appendChild(container);

    copyElement = container.querySelector('[data-controller="clipboard-copy"]');
    copyTargetElement = container.querySelector("#urlCalendarUrl");

    // Wait for the controller to be connected
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(copyElement, "clipboard-copy");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    jest.useRealTimers();
    jest.restoreAllMocks();
  });

  describe("connect", () => {
    it("should initialize with correct properties", () => {
      expect(controller).toBeDefined();
      expect(controller.element).toBe(copyElement);
      expect(controller.targetSelector).toBe("#urlCalendarUrl");
      expect(controller.copyLabel).toBe("Copied!");
      expect(controller.copyMessage).toBe("Text copied to clipboard");
    });

    it("should bind click event listener", () => {
      const addEventListenerSpy = jest.spyOn(copyElement, "addEventListener");

      // Force reconnection to trigger event binding
      controller.disconnect();
      controller.connect();

      expect(addEventListenerSpy).toHaveBeenCalledWith("click", expect.any(Function));

      addEventListenerSpy.mockRestore();

    });
  });

  describe("handleClick", () => {

    it("should prevent default event behavior", () => {
      const mockEvent = { preventDefault: jest.fn() };
      controller.handleClick(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
    });

    it("should return early if no target selector", () => {
      copyElement.dataset.clipboardCopy = "";

      controller.handleClick({ preventDefault: jest.fn() });
      expect(document.execCommand).not.toHaveBeenCalled();
    });

    it("should return early if target element not found", () => {
      copyElement.dataset.clipboardCopy = "#nonexistent";

      controller.handleClick({ preventDefault: jest.fn() });
      expect(document.execCommand).not.toHaveBeenCalled();
    });

    it("should copy text successfully", () => {
      select.mockReturnValue("Test content");

      controller.handleClick({ preventDefault: jest.fn() });

      expect(document.execCommand).toHaveBeenCalledWith("copy");
    });
  });

  describe("_getTextToCopy", () => {
    it("should return custom content if provided", () => {
      select.mockReturnValue("Custom content");

      const result = controller.getTextToCopy(copyTargetElement);
      expect(result).toBe("Custom content");
    });

    it("should use select function for input elements", () => {
      select.mockReturnValue("Selected content");

      const result = controller.getTextToCopy(copyTargetElement);

      expect(select).toHaveBeenCalledWith(copyTargetElement);
      expect(result).toBe("Selected content");
    });

    it("should return empty string for non-input elements without custom content", () => {
      const divElement = document.createElement("div");
      divElement.textContent = "Some text";

      const result = controller.getTextToCopy(divElement);
      expect(result).toBe("");
    });
  });

  describe("_isInputElement", () => {
    it("should return true for input elements", () => {
      expect(controller.isInputElement(copyTargetElement)).toBe(true);
    });

    it("should return true for textarea elements", () => {
      const textarea = document.createElement("textarea");
      expect(controller.isInputElement(textarea)).toBe(true);
    });

    it("should return true for select elements", () => {
      const selectBox = document.createElement("select");
      expect(controller.isInputElement(selectBox)).toBe(true);
    });

    it("should return false for other elements", () => {
      const div = document.createElement("div");
      expect(controller.isInputElement(div)).toBe(false);
    });
  });

  describe("copyToClipboard", () => {

    it("should create temporary textarea and copy text", () => {
      const result = controller.copyToClipboard("Test text");

      expect(document.execCommand).toHaveBeenCalledWith("copy");
      expect(result).toBe(true);
    });

    it("should handle copy failure gracefully", () => {
      document.execCommand.mockImplementation(() => {
        throw new Error("Copy failed");
      });

      const result = controller.copyToClipboard("Test text");
      expect(result).toBe(false);
    });

    it("should focus back to button after copy", () => {
      const focusSpy = jest.spyOn(copyElement, "focus");
      controller.copyToClipboard("Test text");

      expect(focusSpy).toHaveBeenCalled();
    });
  });

  describe("showSuccessMessage", () => {
    it("should show success label and reset after timeout", () => {
      jest.clearAllTimers();
      jest.useFakeTimers();

      const originalContent = copyElement.innerHTML;

      controller.showSuccessMessage(copyTargetElement);

      expect(copyElement.innerHTML).toBe("Copied!");

      jest.advanceTimersByTime(5000);

      expect(copyElement.innerHTML).toBe(originalContent);
    });

    it("should clear existing timeout before setting new one", () => {
      const clearTimeoutSpy = jest.spyOn(global, "clearTimeout");

      controller.showSuccessMessage(copyTargetElement);
      controller.showSuccessMessage(copyTargetElement);

      expect(clearTimeoutSpy).toHaveBeenCalled();
    });

    it("should return early if no copy label", () => {
      controller.copyLabel = "";

      const originalContent = copyElement.innerHTML;
      controller.showSuccessMessage(copyTargetElement);

      expect(copyElement.innerHTML).toBe(originalContent);
    });
  });

  describe("announceToScreenReader", () => {
    it("should create and append screen reader message element", () => {
      controller.announceToScreenReader();

      const messageEl = copyElement.querySelector('[aria-role="alert"]');
      expect(messageEl).toBeTruthy();
      expect(messageEl.getAttribute("aria-live")).toBe("assertive");
      expect(messageEl.getAttribute("aria-atomic")).toBe("true");
      expect(messageEl.className).toBe("sr-only");
    });

    it("should add non-breaking space to force re-announcement", () => {
      controller.announceToScreenReader();
      controller.announceToScreenReader();

      const messageEl = copyElement.querySelector('[aria-role="alert"]');
      expect(messageEl.innerHTML).toContain("&nbsp;");
    });

    it("should return early if no copy message", () => {
      controller.copyMessage = "";

      controller.announceToScreenReader();

      const messageEl = copyElement.querySelector('[aria-role="alert"]');
      expect(messageEl).toBeFalsy();
    });
  });

  describe("disconnect", () => {
    it("should clear timeout and remove message element", () => {
      const clearTimeoutSpy = jest.spyOn(global, "clearTimeout");

      controller.showSuccessMessage(copyTargetElement);
      controller.announceToScreenReader();

      const messageEl = copyElement.querySelector('[aria-role="alert"]');
      expect(messageEl).toBeTruthy();

      controller.disconnect();

      expect(clearTimeoutSpy).toHaveBeenCalled();
      expect(copyElement.querySelector('[role="alert"]')).toBeFalsy();
    });

    it("should remove event listener", () => {
      const removeEventListenerSpy = jest.spyOn(copyElement, "removeEventListener");

      controller.disconnect();

      expect(removeEventListenerSpy).toHaveBeenCalledWith("click", expect.any(Function));
    });
  });

  describe("integration tests", () => {

    /*
     In this spec we clear all the timers, then we simulate a click and after that we test that the
     - Copy command has been attempted
     - The success message is being displayed
     - In the end, we make sure that button comes back to original caption.
     */
    it("should handle complete copy workflow", () => {
      jest.clearAllTimers();
      jest.useFakeTimers();

      const originalContent = copyElement.innerHTML;

      select.mockReturnValue("Test content");

      const clickEvent = new Event("click");
      copyElement.dispatchEvent(clickEvent);

      // Verify copy was attempted
      expect(document.execCommand).toHaveBeenCalledWith("copy");

      expect(copyElement.innerHTML).toBe('Copied!<div aria-role="alert" aria-live="assertive" aria-atomic="true" class="sr-only">Text copied to clipboard</div>');

      const messageEl = copyElement.querySelector('[aria-role="alert"]');
      expect(messageEl.innerHTML).toBe("Text copied to clipboard");

      jest.advanceTimersByTime(5000);
      expect(copyElement.innerHTML).toBe(originalContent);
    });
  });
});
