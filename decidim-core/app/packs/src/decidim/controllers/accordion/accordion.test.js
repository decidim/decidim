/* eslint max-lines: ["error", 350] */
/* global jest */

import AccordionController from "src/decidim/controllers/accordion/controller";
import { screens } from "tailwindcss/defaultTheme"

jest.mock("a11y-accordion-component", () => ({
  render: jest.fn(),
  destroy: jest.fn()
}));

const createController = (controllerElement) => {
  const instance = Object.create(AccordionController.prototype);
  Reflect.defineProperty(instance, "element", {
    get: () => controllerElement,
    configurable: true
  });
  return instance;
};

describe("AccordionController", () => {
  let controller = null;
  let accordionElement = null;
  let panel1 = null;
  let panel2 = null;

  const mockMatchMedia = (matchesOrPredicate = false) => {
    window.matchMedia = jest.fn().mockImplementation((query) => {
      const matches = typeof matchesOrPredicate === "function"
        ? matchesOrPredicate(query)
        : matchesOrPredicate;
      return {
        matches,
        media: query,
        addEventListener: jest.fn(),
        removeEventListener: jest.fn()
      };
    });
  };

  beforeEach(() => {
    mockMatchMedia(false);
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

    it("does nothing when data-panel-role is not set or empty", () => {
      panel1.setAttribute("role", "region");
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
      const trigger = document.createElement("button");
      trigger.dataset.controls = "nonexistent-panel";
      accordionElement.appendChild(trigger);
      expect(() => controller.fixPanelRole()).not.toThrow();
    });
  });

  describe("_setupInertPanels", () => {
    const nextTick = () => new Promise((resolve) => setTimeout(resolve, 0));

    beforeEach(() => {
      panel1.setAttribute("inert", "");
      panel1.setAttribute("aria-hidden", "true");
      panel1.setAttribute("tabindex", "-1");
      panel2.setAttribute("aria-hidden", "true");
    });

    it("only manages panels with the inert attribute", async () => {
      controller._setupInertPanels();
      expect(controller._panelObservers.length).toBe(1);

      panel2.setAttribute("aria-hidden", "false");
      await nextTick();
      expect(panel2.hasAttribute("inert")).toBe(false);
      expect("inertManaged" in panel2.dataset).toBe(false);
    });

    it("removes inert and moves focus to the panel when it gets expanded", async () => {
      controller._setupInertPanels();

      panel1.setAttribute("aria-hidden", "false");
      await nextTick();
      expect(panel1.hasAttribute("inert")).toBe(false);
      expect(document.activeElement).toBe(panel1);
    });

    it("restores inert when the panel gets collapsed again", async () => {
      controller._setupInertPanels();

      panel1.setAttribute("aria-hidden", "false");
      await nextTick();
      panel1.setAttribute("aria-hidden", "true");
      await nextTick();
      expect(panel1.hasAttribute("inert")).toBe(true);
    });

    it("keeps managing an expanded panel across teardown and setup", async () => {
      controller._setupInertPanels();

      panel1.setAttribute("aria-hidden", "false");
      await nextTick();
      controller._teardownInertPanels();

      panel1.setAttribute("aria-hidden", "true");
      controller._setupInertPanels();
      expect(controller._panelObservers.length).toBe(1);
      expect(panel1.hasAttribute("inert")).toBe(true);
    });

    it("stops syncing after teardown", async () => {
      controller._setupInertPanels();
      controller._teardownInertPanels();
      expect(controller._panelObservers.length).toBe(0);

      panel1.setAttribute("aria-hidden", "false");
      await nextTick();
      expect(panel1.hasAttribute("inert")).toBe(true);
    });
  });

  describe("_applyBreakpointOpenAttributes", () => {
    beforeEach(() => {
      controller.initialize();
    });

    it("removes data-open when no breakpoint matches and no original exists", () => {
      accordionElement.innerHTML = `
        <button data-controls="panel-1" data-open-lg="true">Trigger</button>
        <div id="panel-1">Panel 1</div>
      `;
      controller._applyBreakpointOpenAttributes();
      expect(accordionElement.querySelector("[data-controls]").hasAttribute("data-open")).toBe(false);
    });

    it("sets data-open from breakpoint attribute when viewport matches", () => {
      mockMatchMedia((query) => query === `(min-width: ${screens.lg})`);
      accordionElement.innerHTML = `
        <button data-controls="panel-1" data-open-lg="true">Trigger</button>
        <div id="panel-1">Panel 1</div>
      `;
      controller.initialize();
      controller._applyBreakpointOpenAttributes();
      expect(accordionElement.querySelector("[data-controls]").getAttribute("data-open")).toBe("true");
    });

    it("restores original data-open when breakpoint no longer matches", () => {
      const lgQuery = `(min-width: ${screens.lg})`;
      accordionElement.innerHTML = `
        <button data-controls="panel-1" data-open="false" data-open-lg="true">Trigger</button>
        <div id="panel-1">Panel 1</div>
      `;
      const trigger = accordionElement.querySelector("[data-controls]");
      controller.initialize();

      mockMatchMedia((query) => query === lgQuery);
      controller._applyBreakpointOpenAttributes();
      expect(trigger.getAttribute("data-open")).toBe("true");

      mockMatchMedia(() => false);
      controller._applyBreakpointOpenAttributes();
      expect(trigger.getAttribute("data-open")).toBe("false");
    });

    it("removes data-open when breakpoint stops matching and no original existed", () => {
      const lgQuery = `(min-width: ${screens.lg})`;
      accordionElement.innerHTML = `
        <button data-controls="panel-1" data-open-lg="true">Trigger</button>
        <div id="panel-1">Panel 1</div>
      `;
      const trigger = accordionElement.querySelector("[data-controls]");
      controller.initialize();

      mockMatchMedia((query) => query === lgQuery);
      controller._applyBreakpointOpenAttributes();
      expect(trigger.getAttribute("data-open")).toBe("true");

      mockMatchMedia(() => false);
      controller._applyBreakpointOpenAttributes();
      expect(trigger.hasAttribute("data-open")).toBe(false);
    });

    it("applies the last matching breakpoint when multiple match", () => {
      mockMatchMedia((query) =>
        query === `(min-width: ${screens.sm})` || query === `(min-width: ${screens.lg})`
      );
      accordionElement.innerHTML = `
        <button data-controls="panel-1" data-open-sm="false" data-open-lg="true">Trigger</button>
        <div id="panel-1">Panel 1</div>
      `;
      controller.initialize();
      controller._applyBreakpointOpenAttributes();
      expect(accordionElement.querySelector("[data-controls]").getAttribute("data-open")).toBe("true");
    });

    it("leaves triggers without breakpoint attributes unchanged", () => {
      controller.initialize();
      controller._applyBreakpointOpenAttributes();
      expect(accordionElement.querySelector("#trigger-1").hasAttribute("data-open")).toBe(false);
      expect(accordionElement.querySelector("#trigger-2").hasAttribute("data-open")).toBe(false);
    });
  });

  describe("_listenForBreakpointChanges", () => {
    beforeEach(() => {
      controller.initialize();
    });

    it("registers change listeners for breakpoints with matching triggers", () => {
      accordionElement.innerHTML = `
        <button data-controls="panel-1" data-open-lg="true">Trigger</button>
        <div id="panel-1">Panel 1</div>
      `;
      controller._listenForBreakpointChanges();
      expect(window.matchMedia).toHaveBeenCalledWith(`(min-width: ${screens.lg})`);
      expect(window.matchMedia.mock.results[0].value.addEventListener).toHaveBeenCalledWith("change", expect.any(Function));
    });

    it("skips breakpoints without matching triggers", () => {
      accordionElement.innerHTML = `
        <button data-controls="panel-1" data-open-lg="true">Trigger</button>
        <div id="panel-1">Panel 1</div>
      `;
      controller._listenForBreakpointChanges();
      expect(window.matchMedia).toHaveBeenCalledTimes(1);
    });

    it("registers nothing when there are no breakpoint triggers", () => {
      controller._listenForBreakpointChanges();
      expect(controller._mediaQueries.length).toBe(0);
    });

    it("registers listeners for multiple breakpoints", () => {
      accordionElement.innerHTML = `
        <button data-controls="panel-1" data-open-sm="true" data-open-lg="false">Trigger</button>
        <div id="panel-1">Panel 1</div>
      `;
      controller._listenForBreakpointChanges();
      expect(window.matchMedia).toHaveBeenCalledWith(`(min-width: ${screens.sm})`);
      expect(window.matchMedia).toHaveBeenCalledWith(`(min-width: ${screens.lg})`);
      expect(controller._mediaQueries.length).toBe(2);
    });
  });

  describe("_stopListeningForBreakpointChanges", () => {
    beforeEach(() => {
      controller.initialize();
    });

    it("removes all registered change listeners", () => {
      accordionElement.innerHTML = `
        <button data-controls="panel-1" data-open-lg="true">Trigger</button>
        <div id="panel-1">Panel 1</div>
      `;
      controller._listenForBreakpointChanges();
      const mql = window.matchMedia.mock.results[0].value;
      controller._stopListeningForBreakpointChanges();
      expect(mql.removeEventListener).toHaveBeenCalledWith("change", expect.any(Function));
      expect(controller._mediaQueries.length).toBe(0);
    });

    it("does nothing when no listeners exist", () => {
      expect(() => controller._stopListeningForBreakpointChanges()).not.toThrow();
    });
  });

  describe("connect/disconnect/reconnect with breakpoints", () => {
    beforeEach(() => {
      controller.initialize();
    });

    it("connect applies breakpoint attributes and sets up listeners", () => {
      const applySpy = jest.spyOn(controller, "_applyBreakpointOpenAttributes");
      const listenSpy = jest.spyOn(controller, "_listenForBreakpointChanges");
      controller.connect();
      expect(applySpy).toHaveBeenCalled();
      expect(listenSpy).toHaveBeenCalled();
    });

    it("disconnect tears down breakpoint listeners", () => {
      const spy = jest.spyOn(controller, "_stopListeningForBreakpointChanges");
      controller.disconnect();
      expect(spy).toHaveBeenCalled();
    });

    it("reconnect re-evaluates breakpoint attributes", () => {
      const spy = jest.spyOn(controller, "_applyBreakpointOpenAttributes");
      controller.reconnect({});
      expect(spy).toHaveBeenCalled();
    });
  });
});
