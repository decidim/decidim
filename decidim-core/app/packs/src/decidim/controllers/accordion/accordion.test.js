/* global jest */

import AccordionController from "src/decidim/controllers/accordion/controller";

jest.mock("a11y-accordion-component", () => ({
  render: jest.fn(),
  destroy: jest.fn()
}));

describe("AccordionController", () => {
  let controller = null;
  let accordionElement = null;
  let panel1 = null;
  let panel2 = null;

  const createController = (controllerElement) => {
    const ControllerClass = AccordionController;
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
      <div id="test-accordion" data-controller="accordion">
        <button id="trigger-1" data-controls="panel-1">Trigger 1</button>
        <div id="panel-1">Panel 1 Content</div>
        <button id="trigger-2" data-controls="panel-2">Trigger 2</button>
        <div id="panel-2">Panel 2 Content</div>
      </div>
    `;

    accordionElement = document.getElementById("test-accordion");
    panel1 = document.getElementById("panel-1");
    panel2 = document.getElementById("panel-2");

    controller = createController(accordionElement);
  });

  afterEach(() => {
    document.body.innerHTML = "";
    Reflect.deleteProperty(window, "matchMedia");
  });

  describe("fixPanelRole", () => {
    it("changes role from region to group when data-panel-role is group", () => {
      panel1.setAttribute("role", "region");
      panel2.setAttribute("role", "region");

      accordionElement.dataset.panelRole = "group";
      controller.fixPanelRole();

      expect(panel1.getAttribute("role")).toBe("group");
      expect(panel2.getAttribute("role")).toBe("group");
    });

    it("removes role attribute when data-panel-role is none", () => {
      panel1.setAttribute("role", "region");
      panel2.setAttribute("role", "region");

      accordionElement.dataset.panelRole = "none";
      controller.fixPanelRole();

      expect(panel1.getAttribute("role")).toBeNull();
      expect(panel2.getAttribute("role")).toBeNull();
    });

    it("does nothing when data-panel-role is not set", () => {
      panel1.setAttribute("role", "region");
      panel2.setAttribute("role", "region");

      Reflect.deleteProperty(accordionElement.dataset, "panelRole");
      controller.fixPanelRole();

      expect(panel1.getAttribute("role")).toBe("region");
      expect(panel2.getAttribute("role")).toBe("region");
    });

    it("does nothing when data-panel-role is empty", () => {
      panel1.setAttribute("role", "region");

      accordionElement.dataset.panelRole = "";
      controller.fixPanelRole();

      expect(panel1.getAttribute("role")).toBe("region");
    });

    it("sets custom role value when data-panel-role is set", () => {
      panel1.setAttribute("role", "region");

      accordionElement.dataset.panelRole = "navigation";
      controller.fixPanelRole();

      expect(panel1.getAttribute("role")).toBe("navigation");
    });

    it("handles nonexistent panels gracefully", () => {
      accordionElement.dataset.panelRole = "group";

      const nonExistentTrigger = document.createElement("button");
      nonExistentTrigger.dataset.controls = "nonexistent-panel";
      accordionElement.appendChild(nonExistentTrigger);

      expect(() => controller.fixPanelRole()).not.toThrow();
    });
  });
});

