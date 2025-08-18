/* global jest */
import { Application } from "@hotwired/stimulus"
import PasswordTogglerController from "src/decidim/controllers/password_toggler/controller";

// Mock the icon function
jest.mock("src/decidim/icon", () => ({
  __esModule: true,
  default: jest.fn((iconName) => `<svg class="${iconName}"><use href="#${iconName}"></use></svg>`)
}));

describe("PasswordToggler", () => {
  let container = null;
  let passwordElement = null;
  let application = null;
  let controller = null;

  beforeEach(() => {
    // Set up Stimulus application
    application = Application.start();
    application.register("password-toggler", PasswordTogglerController);
    // Set up the DOM structure based on your markup
    container = document.createElement("div");
    container.innerHTML = `
      <div data-controller="password-toggler" class="flex flex-row items-center gap-x-2" data-show-password="Show secret" data-hide-password="Hide Secret" data-hidden-password="Secret is hidden" data-shown-password="Secret is shown">
        <div class="input-group__password">
          <div class="input-group__password">
            <button type="button" aria-controls="token_162" aria-label="Show password">
              <svg width="0.75em" height="0.75em" role="img" aria-hidden="true">
                <title>eye-line</title>
                <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-eye-line"></use>
              </svg>
            </button>
            <input type="password" id="token_162" value="AXXXXXXXX" class="w-full" autocomplete="off">
          </div>
        </div>
        <div class="basis-1/4">
          <button type="button" class="button button__sm button__text-primary" data-clipboard-copy="#token_162">
            <span>Copy secret</span>
          </button>
        </div>
      </div>
    `;

    document.body.appendChild(container);
    passwordElement = container.querySelector('[data-controller="password-toggler"]');
    // Wait for the controller to be connected
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(passwordElement, "password-toggler");
        resolve();
      }, 0);
    });

  });

  afterEach(() => {
    application.stop();
    document.body.removeChild(container);
    jest.clearAllMocks();
  });

  describe("constructor", () => {
    it("initializes with correct properties", () => {
      expect(controller.element).toBe(passwordElement);
      expect(controller.input).toBe(passwordElement.querySelector('input[type="password"]'));
      expect(controller.texts.showPassword).toBe("Show secret");
      expect(controller.texts.hidePassword).toBe("Hide Secret");
      expect(controller.texts.hiddenPassword).toBe("Secret is hidden");
      expect(controller.texts.shownPassword).toBe("Secret is shown");
    });

    it("falls back to default texts when data attributes are not provided", async () => {
      const simpleContainer = document.createElement("div");
      simpleContainer.innerHTML = `
        <div data-controller="password-toggler">
          <input type="password" id="simple_password">
        </div>
      `;
      document.body.appendChild(simpleContainer);

      const simplePasswordElement = simpleContainer.querySelector('[data-controller="password-toggler"]');

      await new Promise((resolve) => setTimeout(resolve, 0));
      const simpleController = application.getControllerForElementAndIdentifier(simplePasswordElement, "password-toggler");

      expect(simpleController.texts.showPassword).toBe("Show password");
      expect(simpleController.texts.hidePassword).toBe("Hide password");
      expect(simpleController.texts.hiddenPassword).toBe("Your password is hidden");
      expect(simpleController.texts.shownPassword).toBe("Your password is shown");

      document.body.removeChild(simpleContainer);
    });
  });

  describe("init", () => {
    it("creates controls and adds event listeners", () => {
      const addEventListenerSpy = jest.spyOn(HTMLElement.prototype, "addEventListener");

      controller.init();

      expect(controller.button).toBeDefined();
      expect(controller.statusText).toBeDefined();
      expect(addEventListenerSpy).toHaveBeenCalledWith("click", expect.any(Function));

      addEventListenerSpy.mockRestore();
    });
  });

  describe("createButton", () => {
    it("creates button with correct attributes", () => {
      expect(controller.button.tagName).toBe("BUTTON");
      expect(controller.button.getAttribute("type")).toBe("button");
      expect(controller.button.getAttribute("aria-controls")).toBe("token_162");
      expect(controller.button.getAttribute("aria-label")).toBe("Show secret");
    });
  });

  describe("createStatusText", () => {
    it("creates status text with correct attributes", () => {

      expect(controller.statusText.tagName).toBe("SPAN");
      expect(controller.statusText.classList.contains("sr-only")).toBe(true);
      expect(controller.statusText.getAttribute("aria-live")).toBe("polite");
      expect(controller.statusText.textContent).toBe("Secret is hidden");
    });
  });

  describe("toggleVisibility", () => {

    it("shows password when currently hidden", () => {
      const mockEvent = { preventDefault: jest.fn() };
      controller.input.setAttribute("type", "password");

      controller.toggleVisibility(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(controller.input.getAttribute("type")).toBe("text");
      expect(controller.button.getAttribute("aria-label")).toBe("Hide Secret");
      expect(controller.statusText.textContent).toBe("Secret is shown");
    });

    it("hides password when currently shown", () => {
      const mockEvent = { preventDefault: jest.fn() };
      controller.input.setAttribute("type", "text");

      controller.toggleVisibility(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(controller.input.getAttribute("type")).toBe("password");
      expect(controller.button.getAttribute("aria-label")).toBe("Show secret");
      expect(controller.statusText.textContent).toBe("Secret is hidden");
    });
  });

  describe("showPassword", () => {
    it("changes input type to text and updates button", () => {
      controller.showPassword();

      expect(controller.input.getAttribute("type")).toBe("text");
      expect(controller.button.getAttribute("aria-label")).toBe("Hide Secret");
      expect(controller.statusText.textContent).toBe("Secret is shown");
      expect(controller.button.innerHTML).toContain("eye-off-line");
    });
  });

  describe("hidePassword", () => {


    it("changes input type to password and updates button", () => {
      controller.hidePassword();

      expect(controller.input.getAttribute("type")).toBe("password");
      expect(controller.button.getAttribute("aria-label")).toBe("Show secret");
      expect(controller.statusText.textContent).toBe("Secret is hidden");
      expect(controller.button.innerHTML).toContain("eye-line");
    });
  });

  describe("isText", () => {
    it("returns true when input type is text", () => {
      controller.input.setAttribute("type", "text");
      expect(controller.isText()).toBe(true);
    });

    it("returns false when input type is password", () => {
      controller.input.setAttribute("type", "password");
      expect(controller.isText()).toBe(false);
    });
  });

  describe("form submission", () => {
    it("resets password type on form submit", () => {
      const form = document.createElement("form");
      form.appendChild(passwordElement);
      controller.form = form;

      controller.init();
      controller.input.setAttribute("type", "text");

      const submitEvent = new Event("submit");
      form.dispatchEvent(submitEvent);

      expect(controller.input.getAttribute("type")).toBe("password");
    });
  });

  describe("integration with existing markup", () => {
    it("works with existing button structure", () => {
      const existingButton = passwordElement.querySelector('button[aria-controls="token_162"]');
      expect(existingButton).toBeTruthy();

      controller.init();

      // Should work alongside existing button
      expect(controller.button).toBeDefined();
      expect(controller.input.getAttribute("type")).toBe("password");
    });

    it("handles password input with existing value", () => {
      expect(controller.input.value).toBe("AXXXXXXXX");

      controller.init();
      controller.showPassword();

      expect(controller.input.getAttribute("type")).toBe("text");
      expect(controller.input.value).toBe("AXXXXXXXX");
    });
  });
});
