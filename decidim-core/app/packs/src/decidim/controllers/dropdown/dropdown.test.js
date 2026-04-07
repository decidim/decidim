/* global jest */
/* eslint max-lines: ["error", 400] */

import DropdownController from "src/decidim/controllers/dropdown/controller";

jest.mock("a11y-dropdown-component", () => ({
  render: jest.fn(),
  destroy: jest.fn()
}));

describe("DropdownController", () => {
  let element = null;
  let dropdownMenuEl = null;
  let controller = null;

  const createController = (controllerElement) => {
    const ControllerClass = DropdownController;
    const instance = Object.create(ControllerClass.prototype);
    Reflect.defineProperty(instance, "element", {
      get: () => controllerElement,
      configurable: true
    });
    return instance;
  };

  beforeEach(() => {
    window.matchMedia = jest.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      addListener: jest.fn(),
      removeListener: jest.fn()
    }));

    document.body.innerHTML = `
      <button
        id="dropdown-trigger"
        data-controller="dropdown"
        data-target="dropdown-menu"
        data-open-md="true"
        data-auto-close="true"
      >
        Dropdown Trigger
      </button>
      <ul id="dropdown-menu" class="dropdown-menu">
        <li><a href="/link1">Link 1</a></li>
        <li><a href="/link2">Link 2</a></li>
        <li><a href="/link3">Link 3</a></li>
      </ul>
    `;

    element = document.getElementById("dropdown-trigger");
    dropdownMenuEl = document.getElementById("dropdown-menu");
    controller = createController(element);
  });

  afterEach(() => {
    document.body.innerHTML = "";
    Reflect.deleteProperty(window, "matchMedia");
  });

  describe("removeAriaRoles", () => {
    it("removes role attribute from dropdown menu", () => {
      dropdownMenuEl.setAttribute("role", "menu");

      controller.removeAriaRoles();

      expect(dropdownMenuEl.getAttribute("role")).toBeNull();
    });

    it("removes aria-labelledby attribute from dropdown menu", () => {
      dropdownMenuEl.setAttribute("aria-labelledby", "trigger");

      controller.removeAriaRoles();

      expect(dropdownMenuEl.getAttribute("aria-labelledby")).toBeNull();
    });

    it("removes tabindex attribute from dropdown menu", () => {
      dropdownMenuEl.setAttribute("tabindex", "-1");

      controller.removeAriaRoles();

      expect(dropdownMenuEl.getAttribute("tabindex")).toBeNull();
    });

    it("removes role from li elements", () => {
      const li = dropdownMenuEl.querySelector("li");
      li.setAttribute("role", "none");

      controller.removeAriaRoles();

      expect(li.getAttribute("role")).toBeNull();
    });

    it("removes role from all li elements", () => {
      const listItems = dropdownMenuEl.querySelectorAll("li");
      listItems.forEach((li) => {
        li.setAttribute("role", "none");
      });

      controller.removeAriaRoles();

      listItems.forEach((li) => {
        expect(li.getAttribute("role")).toBeNull();
      });
    });

    it("removes role from anchor elements", () => {
      const anchor = dropdownMenuEl.querySelector("a");
      anchor.setAttribute("role", "menuitem");

      controller.removeAriaRoles();

      expect(anchor.getAttribute("role")).toBeNull();
    });

    it("removes tabindex from anchor elements", () => {
      const anchor = dropdownMenuEl.querySelector("a");
      anchor.setAttribute("tabindex", "-1");

      controller.removeAriaRoles();

      expect(anchor.getAttribute("tabindex")).toBeNull();
    });

    it("handles missing dropdown menu gracefully", () => {
      const mockElement = document.createElement("button");
      mockElement.dataset.target = "nonexistent-menu";
      const mockController = createController(mockElement);

      expect(() => {
        mockController.removeAriaRoles();
      }).not.toThrow();
    });

    it("handles elements without the attributes gracefully", () => {
      expect(() => {
        controller.removeAriaRoles();
      }).not.toThrow();

      expect(dropdownMenuEl.getAttribute("role")).toBeNull();
    });
  });

  describe("data-add-aria-roles option", () => {
    it("keeps role menu when data-add-aria-roles is true", () => {
      element.setAttribute("data-add-aria-roles", "true");
      dropdownMenuEl.setAttribute("role", "menu");
      dropdownMenuEl.querySelector("li").setAttribute("role", "none");
      dropdownMenuEl.querySelector("a").setAttribute("role", "menuitem");
      const testController = createController(element);

      testController.connect();

      expect(dropdownMenuEl.getAttribute("role")).toBe("menu");
      expect(dropdownMenuEl.querySelector("li").getAttribute("role")).toBe("none");
      expect(dropdownMenuEl.querySelector("a").getAttribute("role")).toBe("menuitem");
    });

    it("keeps role menu when data-add-aria-roles is not set (default)", () => {
      dropdownMenuEl.setAttribute("role", "menu");
      dropdownMenuEl.querySelector("li").setAttribute("role", "none");
      dropdownMenuEl.querySelector("a").setAttribute("role", "menuitem");
      const testController = createController(element);

      testController.connect();

      expect(dropdownMenuEl.getAttribute("role")).toBe("menu");
      expect(dropdownMenuEl.querySelector("li").getAttribute("role")).toBe("none");
      expect(dropdownMenuEl.querySelector("a").getAttribute("role")).toBe("menuitem");
    });

    it("removes role menu when data-add-aria-roles is false", () => {
      element.setAttribute("data-add-aria-roles", "false");
      dropdownMenuEl.setAttribute("role", "menu");
      dropdownMenuEl.querySelector("li").setAttribute("role", "none");
      dropdownMenuEl.querySelector("a").setAttribute("role", "menuitem");
      const testController = createController(element);

      testController.connect();

      expect(dropdownMenuEl.getAttribute("role")).toBeNull();
      expect(dropdownMenuEl.querySelector("li").getAttribute("role")).toBeNull();
      expect(dropdownMenuEl.querySelector("a").getAttribute("role")).toBeNull();
    });
  });
});
