import { Application } from "@hotwired/stimulus"
import ViewMoreToggleController from "src/decidim/controllers/view_more_toggle/controller"

describe("ViewMoreToggleController", () => {
  let application = null;
  let button = null;
  let panel = null;

  beforeEach(() => {
    document.body.innerHTML = `
      <div class="content-block__description" data-controller="accordion">
        <div id="panel-view-more-aaaa" inert></div>
        <button data-controller="view-more-toggle" data-controls="panel-view-more-aaaa" data-action="click->view-more-toggle#toggle keydown->view-more-toggle#toggle">
          <span>View more</span>
        </button>
      </div>
    `;

    button = document.querySelector("[data-controller='view-more-toggle']");
    panel = document.getElementById("panel-view-more-aaaa");

    application = Application.start();
    application.register("view-more-toggle", ViewMoreToggleController);

    return new Promise((resolve) => {
      setTimeout(resolve, 0);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
  });

  describe("toggle", () => {
    it("removes inert on the panel on click", () => {
      button.dispatchEvent(new MouseEvent("click", { bubbles: true }));

      expect(panel.hasAttribute("inert")).toBe(false);
    });

    it("re-adds inert on the panel on a second click", () => {
      button.dispatchEvent(new MouseEvent("click", { bubbles: true }));
      button.dispatchEvent(new MouseEvent("click", { bubbles: true }));

      expect(panel.hasAttribute("inert")).toBe(true);
    });

    it("toggles inert on Enter keydown", () => {
      button.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 13, bubbles: true }));

      expect(panel.hasAttribute("inert")).toBe(false);
    });

    it("toggles inert on Space keydown", () => {
      button.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 32, bubbles: true }));

      expect(panel.hasAttribute("inert")).toBe(false);
    });

    it("ignores keys other than Enter and Space", () => {
      button.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 27, bubbles: true }));

      expect(panel.hasAttribute("inert")).toBe(true);
    });
  });

  describe("multiple instances", () => {
    let secondButton = null;
    let secondPanel = null;

    beforeEach(() => {
      document.body.innerHTML = `
        <div class="content-block__description" data-controller="accordion">
          <div id="panel-view-more-aaaa" inert></div>
          <button data-controller="view-more-toggle" data-controls="panel-view-more-aaaa" data-action="click->view-more-toggle#toggle keydown->view-more-toggle#toggle">first</button>
        </div>
        <div class="content-block__description" data-controller="accordion">
          <div id="panel-view-more-bbbb" inert></div>
          <button data-controller="view-more-toggle" data-controls="panel-view-more-bbbb" data-action="click->view-more-toggle#toggle keydown->view-more-toggle#toggle">second</button>
        </div>
      `;

      const buttons = document.querySelectorAll("[data-controller='view-more-toggle']");
      button = buttons[0];
      panel = document.getElementById("panel-view-more-aaaa");
      secondButton = buttons[1];
      secondPanel = document.getElementById("panel-view-more-bbbb");

      return new Promise((resolve) => {
        setTimeout(resolve, 0);
      });
    });

    it("toggles only the first instance's panel when its button is clicked", () => {
      button.dispatchEvent(new MouseEvent("click", { bubbles: true }));

      expect(panel.hasAttribute("inert")).toBe(false);
      expect(secondPanel.hasAttribute("inert")).toBe(true);
    });

    it("toggles only the second instance's panel when its button is clicked", () => {
      secondButton.dispatchEvent(new MouseEvent("click", { bubbles: true }));

      expect(secondPanel.hasAttribute("inert")).toBe(false);
      expect(panel.hasAttribute("inert")).toBe(true);
    });
  });
});
