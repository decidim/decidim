/* global jest */
/* eslint max-lines: ["error", 550] */

import { Application } from "@hotwired/stimulus";
import TabsController from "src/decidim/controllers/tabs/controller";

describe("TabsController", () => {
  let application = null;
  let controller = null;
  let tablistElement = null;
  let tabs = null;
  let panels = null;

  beforeEach(() => {
    document.body.innerHTML = `
  <div class="row column">
    <div class="label--tabs">
      <label for="participatory_process_title">Title</label>
      <ul class="tabs tabs--lang" role="tablist" id="participatory_process-title-tabs" data-controller="tabs">
        <li class="tabs-title is-active" role="presentation">
          <a href="#participatory_process-title-tabs-title-panel-0"
             role="tab"
             aria-selected="true"
             aria-controls="participatory_process-title-tabs-title-panel-0">English</a>
        </li>
        <li class="tabs-title" role="presentation">
          <a href="#participatory_process-title-tabs-title-panel-1"
             role="tab"
             aria-selected="false"
             aria-controls="participatory_process-title-tabs-title-panel-1"
             tabindex="-1">Castellano</a>
        </li>
        <li class="tabs-title" role="presentation">
          <a href="#participatory_process-title-tabs-title-panel-2"
             role="tab"
             aria-selected="false"
             aria-controls="participatory_process-title-tabs-title-panel-2"
             tabindex="-1">Català</a>
        </li>
      </ul>
    </div>
    <div class="tabs-content" data-tabs-content="participatory_process-title-tabs">
      <div class="tabs-panel is-active" id="participatory_process-title-tabs-title-panel-0" aria-hidden="false">
        <input type="text" value="English value" name="participatory_process[title_en]" id="participatory_process_title_en">
      </div>
      <div class="tabs-panel is-hidden" id="participatory_process-title-tabs-title-panel-1" aria-hidden="true">
        <input type="text" value="Castellano value" name="participatory_process[title_es]" id="participatory_process_title_es">
      </div>
      <div class="tabs-panel is-hidden" id="participatory_process-title-tabs-title-panel-2" aria-hidden="true">
        <input type="text" value="" name="participatory_process[title_ca]" id="participatory_process_title_ca">
      </div>
    </div>
  </div>
`;

    application = Application.start();
    application.register("tabs", TabsController);

    tablistElement = document.querySelector('[data-controller="tabs"]');
    tabs = Array.from(tablistElement.querySelectorAll("[role=tab]"));
    panels = [
      document.getElementById("participatory_process-title-tabs-title-panel-0"),
      document.getElementById("participatory_process-title-tabs-title-panel-1"),
      document.getElementById("participatory_process-title-tabs-title-panel-2")
    ];

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(tablistElement, "tabs");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
    jest.clearAllMocks();
  });

  describe("connect", () => {
    it("initializes the tabs array from [role=tab] elements", () => {
      expect(controller.tabs).toHaveLength(3);
    });

    it("sets firstTab and lastTab correctly", () => {
      expect(controller.firstTab).toBe(tabs[0]);
      expect(controller.lastTab).toBe(tabs[2]);
    });

    it("initializes all tabs with tabIndex -1 and aria-selected false, then selects the first", () => {
      // After connect, first tab is selected (no tabIndex, aria-selected true)
      expect(tabs[0].getAttribute("aria-selected")).toBe("true");
      expect(tabs[0].hasAttribute("tabindex")).toBe(false);

      // Remaining tabs are deselected
      expect(tabs[1].getAttribute("aria-selected")).toBe("false");
      expect(tabs[1].tabIndex).toBe(-1);
      expect(tabs[2].getAttribute("aria-selected")).toBe("false");
      expect(tabs[2].tabIndex).toBe(-1);
    });

    it("selects the first tab panel on connect without focusing", () => {
      expect(panels[0].classList.contains("is-hidden")).toBe(false);
      expect(panels[0].getAttribute("aria-hidden")).toBe("false");
      expect(panels[1].classList.contains("is-hidden")).toBe(true);
      expect(panels[1].getAttribute("aria-hidden")).toBe("true");
      expect(panels[2].classList.contains("is-hidden")).toBe(true);
      expect(panels[2].getAttribute("aria-hidden")).toBe("true");
    });
  });

  describe("disconnect", () => {
    it("removes keydown event listeners from all tabs", () => {
      const spies = tabs.map((tab) => jest.spyOn(tab, "removeEventListener"));

      controller.disconnect();

      spies.forEach((spy) => {
        expect(spy).toHaveBeenCalledWith("keydown", controller._onKeydown);
      });
    });

    it("removes click event listeners from all tabs", () => {
      const spies = tabs.map((tab) => jest.spyOn(tab, "removeEventListener"));

      controller.disconnect();

      spies.forEach((spy) => {
        expect(spy).toHaveBeenCalledWith("click", controller._onClick);
      });
    });
  });

  describe("setSelectedTab", () => {
    it("marks the given tab as selected and shows its panel", () => {
      controller.setSelectedTab(tabs[1], false);

      expect(tabs[1].getAttribute("aria-selected")).toBe("true");
      expect(tabs[1].hasAttribute("tabindex")).toBe(false);
      expect(panels[1].classList.contains("is-hidden")).toBe(false);
      expect(panels[1].getAttribute("aria-hidden")).toBe("false");
    });

    it("deselects and hides all other tabs and panels", () => {
      controller.setSelectedTab(tabs[1], false);

      [0, 2].forEach((index) => {
        expect(tabs[index].getAttribute("aria-selected")).toBe("false");
        expect(tabs[index].tabIndex).toBe(-1);
        expect(panels[index].classList.contains("is-hidden")).toBe(true);
        expect(panels[index].getAttribute("aria-hidden")).toBe("true");
      });
    });

    it("focuses the tab when setFocus is true", () => {
      const focusSpy = jest.spyOn(tabs[2], "focus");

      controller.setSelectedTab(tabs[2], true);

      expect(focusSpy).toHaveBeenCalled();
    });

    it("does not focus the tab when setFocus is false", () => {
      const focusSpy = jest.spyOn(tabs[2], "focus");

      controller.setSelectedTab(tabs[2], false);

      expect(focusSpy).not.toHaveBeenCalled();
    });

    it("defaults setFocus to true when omitted", () => {
      const focusSpy = jest.spyOn(tabs[1], "focus");

      controller.setSelectedTab(tabs[1]);

      expect(focusSpy).toHaveBeenCalled();
    });
  });

  describe("setSelectedToPreviousTab", () => {
    it("moves to the previous tab", () => {
      controller.setSelectedTab(tabs[2], false);
      controller.setSelectedToPreviousTab(tabs[2]);

      expect(tabs[1].getAttribute("aria-selected")).toBe("true");
    });

    it("wraps around to the last tab when on the first tab", () => {
      controller.setSelectedToPreviousTab(tabs[0]);

      expect(tabs[2].getAttribute("aria-selected")).toBe("true");
    });
  });

  describe("setSelectedToNextTab", () => {
    it("moves to the next tab", () => {
      controller.setSelectedToNextTab(tabs[0]);

      expect(tabs[1].getAttribute("aria-selected")).toBe("true");
    });

    it("wraps around to the first tab when on the last tab", () => {
      controller.setSelectedTab(tabs[2], false);
      controller.setSelectedToNextTab(tabs[2]);

      expect(tabs[0].getAttribute("aria-selected")).toBe("true");
    });
  });

  describe("onKeydown", () => {
    const dispatchKey = (tab, key) => {
      const event = new KeyboardEvent("keydown", { key, bubbles: true, cancelable: true });
      tab.dispatchEvent(event);
      return event;
    };

    beforeEach(() => {
      // Start on tab[1] for easier prev/next testing
      controller.setSelectedTab(tabs[1], false);
    });

    it("ArrowLeft selects the previous tab", () => {
      dispatchKey(tabs[1], "ArrowLeft");

      expect(tabs[0].getAttribute("aria-selected")).toBe("true");
    });

    it("ArrowRight selects the next tab", () => {
      dispatchKey(tabs[1], "ArrowRight");

      expect(tabs[2].getAttribute("aria-selected")).toBe("true");
    });

    it("Home selects the first tab", () => {
      dispatchKey(tabs[1], "Home");

      expect(tabs[0].getAttribute("aria-selected")).toBe("true");
    });

    it("End selects the last tab", () => {
      dispatchKey(tabs[1], "End");

      expect(tabs[2].getAttribute("aria-selected")).toBe("true");
    });

    it("prevents default and stops propagation for navigation keys", () => {
      const event = new KeyboardEvent("keydown", { key: "ArrowLeft", bubbles: true, cancelable: true });
      const preventDefaultSpy = jest.spyOn(event, "preventDefault");
      const stopPropagationSpy = jest.spyOn(event, "stopPropagation");

      tabs[1].dispatchEvent(event);

      expect(preventDefaultSpy).toHaveBeenCalled();
      expect(stopPropagationSpy).toHaveBeenCalled();
    });

    it("does not prevent default for non-navigation keys", () => {
      const event = new KeyboardEvent("keydown", { key: "Tab", bubbles: true, cancelable: true });
      const preventDefaultSpy = jest.spyOn(event, "preventDefault");

      tabs[1].dispatchEvent(event);

      expect(preventDefaultSpy).not.toHaveBeenCalled();
    });
  });

  describe("onClick", () => {
    it("selects the clicked tab", () => {
      tabs[2].click();

      expect(tabs[2].getAttribute("aria-selected")).toBe("true");
      expect(panels[2].classList.contains("is-hidden")).toBe(false);
      expect(panels[2].getAttribute("aria-hidden")).toBe("false");
    });

    it("deselects the previously active tab on click", () => {
      tabs[2].click();

      expect(tabs[0].getAttribute("aria-selected")).toBe("false");
      expect(panels[0].classList.contains("is-hidden")).toBe(true);
    });

    it("prevents default link navigation on click", () => {
      const event = new MouseEvent("click", { bubbles: true, cancelable: true });
      const preventDefaultSpy = jest.spyOn(event, "preventDefault");

      tabs[1].dispatchEvent(event);

      expect(preventDefaultSpy).toHaveBeenCalled();
    });
  });

  describe("detectAndSetActiveTab", () => {
    const setupWithActiveTab = (activeIndex) => {
      const liClasses = ["tabs-title", "tabs-title", "tabs-title"];
      const panelClasses = ["is-hidden", "is-hidden", "is-hidden"];

      liClasses[activeIndex] = "tabs-title is-active";
      panelClasses[activeIndex] = "is-active";

      application.stop();
      document.body.innerHTML = `
  <div class="row column">
    <div class="label--tabs">
      <ul class="tabs tabs--lang" role="tablist" id="backend-tabs" data-controller="tabs">
        <li class="${liClasses[0]}" role="presentation">
          <a href="#backend-panel-0" role="tab" aria-controls="backend-panel-0">English</a>
        </li>
        <li class="${liClasses[1]}" role="presentation">
          <a href="#backend-panel-1" role="tab" aria-controls="backend-panel-1">Castellano</a>
        </li>
        <li class="${liClasses[2]}" role="presentation">
          <a href="#backend-panel-2" role="tab" aria-controls="backend-panel-2">Català</a>
        </li>
      </ul>
    </div>
    <div class="tabs-content">
      <div class="tabs-panel ${panelClasses[0]}" id="backend-panel-0"></div>
      <div class="tabs-panel ${panelClasses[1]}" id="backend-panel-1"></div>
      <div class="tabs-panel ${panelClasses[2]}" id="backend-panel-2"></div>
    </div>
  </div>
`;
      application = Application.start();
      application.register("tabs", TabsController);
      tablistElement = document.querySelector('[data-controller="tabs"]');

      return new Promise((resolve) => {
        setTimeout(() => {
          controller = application.getControllerForElementAndIdentifier(tablistElement, "tabs");
          tabs = Array.from(tablistElement.querySelectorAll("[role=tab]"));
          panels = [
            document.getElementById("backend-panel-0"),
            document.getElementById("backend-panel-1"),
            document.getElementById("backend-panel-2")
          ];
          resolve();
        }, 0);
      });
    };

    describe("when the second tab has is-active set by the backend", () => {
      beforeEach(() => setupWithActiveTab(1));

      it("selects the backend-active tab, not the first tab", () => {
        expect(tabs[1].getAttribute("aria-selected")).toBe("true");
        expect(tabs[0].getAttribute("aria-selected")).toBe("false");
        expect(tabs[2].getAttribute("aria-selected")).toBe("false");
      });

      it("removes tabindex from the backend-active tab", () => {
        expect(tabs[1].hasAttribute("tabindex")).toBe(false);
        expect(tabs[0].tabIndex).toBe(-1);
        expect(tabs[2].tabIndex).toBe(-1);
      });

      it("shows only the panel for the backend-active tab", () => {
        expect(panels[1].classList.contains("is-hidden")).toBe(false);
        expect(panels[1].getAttribute("aria-hidden")).toBe("false");
        expect(panels[0].classList.contains("is-hidden")).toBe(true);
        expect(panels[0].getAttribute("aria-hidden")).toBe("true");
        expect(panels[2].classList.contains("is-hidden")).toBe(true);
        expect(panels[2].getAttribute("aria-hidden")).toBe("true");
      });
    });

    describe("when the last tab has is-active set by the backend", () => {
      beforeEach(() => setupWithActiveTab(2));

      it("selects the backend-active last tab", () => {
        expect(tabs[2].getAttribute("aria-selected")).toBe("true");
        expect(tabs[0].getAttribute("aria-selected")).toBe("false");
        expect(tabs[1].getAttribute("aria-selected")).toBe("false");
      });

      it("removes tabindex from the backend-active last tab", () => {
        expect(tabs[2].hasAttribute("tabindex")).toBe(false);
        expect(tabs[0].tabIndex).toBe(-1);
        expect(tabs[1].tabIndex).toBe(-1);
      });

      it("shows only the panel for the backend-active last tab", () => {
        expect(panels[2].classList.contains("is-hidden")).toBe(false);
        expect(panels[2].getAttribute("aria-hidden")).toBe("false");
        expect(panels[0].classList.contains("is-hidden")).toBe(true);
        expect(panels[0].getAttribute("aria-hidden")).toBe("true");
        expect(panels[1].classList.contains("is-hidden")).toBe(true);
        expect(panels[1].getAttribute("aria-hidden")).toBe("true");
      });
    });

    describe("when no tab has is-active set by the backend", () => {
      beforeEach(() => {
        application.stop();
        document.body.innerHTML = `
  <div class="row column">
    <div class="label--tabs">
      <ul class="tabs tabs--lang" role="tablist" id="backend-tabs" data-controller="tabs">
        <li class="tabs-title" role="presentation">
          <a href="#backend-panel-0" role="tab" aria-controls="backend-panel-0">English</a>
        </li>
        <li class="tabs-title" role="presentation">
          <a href="#backend-panel-1" role="tab" aria-controls="backend-panel-1">Castellano</a>
        </li>
        <li class="tabs-title" role="presentation">
          <a href="#backend-panel-2" role="tab" aria-controls="backend-panel-2">Català</a>
        </li>
      </ul>
    </div>
    <div class="tabs-content">
      <div class="tabs-panel" id="backend-panel-0"></div>
      <div class="tabs-panel" id="backend-panel-1"></div>
      <div class="tabs-panel" id="backend-panel-2"></div>
    </div>
  </div>
`;
        application = Application.start();
        application.register("tabs", TabsController);
        tablistElement = document.querySelector('[data-controller="tabs"]');

        return new Promise((resolve) => {
          setTimeout(() => {
            controller = application.getControllerForElementAndIdentifier(tablistElement, "tabs");
            tabs = Array.from(tablistElement.querySelectorAll("[role=tab]"));
            panels = [
              document.getElementById("backend-panel-0"),
              document.getElementById("backend-panel-1"),
              document.getElementById("backend-panel-2")
            ];
            resolve();
          }, 0);
        });
      });

      it("falls back to selecting the first tab", () => {
        expect(tabs[0].getAttribute("aria-selected")).toBe("true");
        expect(tabs[1].getAttribute("aria-selected")).toBe("false");
        expect(tabs[2].getAttribute("aria-selected")).toBe("false");
      });

      it("shows only the first panel", () => {
        expect(panels[0].classList.contains("is-hidden")).toBe(false);
        expect(panels[0].getAttribute("aria-hidden")).toBe("false");
        expect(panels[1].classList.contains("is-hidden")).toBe(true);
        expect(panels[2].classList.contains("is-hidden")).toBe(true);
      });
    });
  });

  describe("integration", () => {

    const dispatchKeyOn = (tab, key) => {
      tab.dispatchEvent(new KeyboardEvent("keydown", { key, bubbles: true, cancelable: true }));
    }


    it("clicking through all tabs shows the correct panel each time", () => {
      tabs.forEach((tab, index) => {
        tab.click();

        panels.forEach((panel, panelIndex) => {
          if (panelIndex === index) {
            expect(panel.classList.contains("is-hidden")).toBe(false);
            expect(panel.getAttribute("aria-hidden")).toBe("false");
          } else {
            expect(panel.classList.contains("is-hidden")).toBe(true);
            expect(panel.getAttribute("aria-hidden")).toBe("true");
          }
        });
      });
    });

    it("keyboard navigation cycles through all tabs with ArrowRight", () => {
      // Start on first tab, cycle forward
      // → tab[1]
      dispatchKeyOn(tabs[0], "ArrowRight");
      expect(tabs[1].getAttribute("aria-selected")).toBe("true");
      // → tab[2]
      dispatchKeyOn(tabs[1], "ArrowRight");
      expect(tabs[2].getAttribute("aria-selected")).toBe("true");
      // wraps → tab[0]
      dispatchKeyOn(tabs[2], "ArrowRight");
      expect(tabs[0].getAttribute("aria-selected")).toBe("true");
    });

    it("keyboard navigation cycles through all tabs with ArrowLeft", () => {
      // Start on first tab, wrap left
      // wraps → tab[2]
      dispatchKeyOn(tabs[0], "ArrowLeft");
      expect(tabs[2].getAttribute("aria-selected")).toBe("true");
      // → tab[1]
      dispatchKeyOn(tabs[2], "ArrowLeft");
      expect(tabs[1].getAttribute("aria-selected")).toBe("true");
      // → tab[0]
      dispatchKeyOn(tabs[1], "ArrowLeft");
      expect(tabs[0].getAttribute("aria-selected")).toBe("true");
    });
  });
});
