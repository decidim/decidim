/* global jest */
/**
 * @jest-environment jsdom
 */
import { Application } from "@hotwired/stimulus";
import PublicParticipantsController from "src/decidim/meetings/controllers/public_participants/controller";

describe("PublicParticipantsController", () => {
  let application = null;
  let controller = null;
  let element = null;
  let mediaQuery = null;

  const buildParticipants = (count) => Array.from({ length: count }, (_el, index) => (
    `<div class="meeting__public-participants-item" data-participants-item>Participant ${index + 1}</div>`
  )).join("");

  const buildDom = ({
    itemsCount = 4,
    desktopCount = 5,
    mobileCount = 2
  } = {}) => {
    document.body.innerHTML = `
      <div
        data-controller="public-participants"
        data-desktop-count="${desktopCount}"
        data-mobile-count="${mobileCount}"
      >
        ${buildParticipants(itemsCount)}
        <button
          class="meeting__public-participants-toggle hidden"
          type="button"
          data-action="click->public-participants#toggle"
          data-participants-toggle
          aria-expanded="false"
        >
          <div data-participants-toggle-more>Show more</div>
          <div class="hidden" data-participants-toggle-less>Show less</div>
        </button>
      </div>
    `;
  };

  beforeEach(() => {
    mediaQuery = {
      matches: false,
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
      addListener: jest.fn(),
      removeListener: jest.fn()
    };

    window.matchMedia = jest.fn().mockImplementation(() => mediaQuery);
    application = Application.start();
    application.register("public-participants", PublicParticipantsController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
    jest.clearAllMocks();
  });

  const connectController = () => new Promise((resolve) => {
    setTimeout(() => {
      element = document.querySelector('[data-controller="public-participants"]');
      controller = application.getControllerForElementAndIdentifier(element, "public-participants");
      resolve();
    }, 0);
  });

  describe("connect and refresh", () => {
    it("hides the toggle when all items fit", async () => {
      mediaQuery.matches = true;
      buildDom({ itemsCount: 3, desktopCount: 5, mobileCount: 2 });

      await connectController();

      const toggle = element.querySelector("[data-participants-toggle]");
      const items = element.querySelectorAll("[data-participants-item]");

      expect(controller.expanded).toBe(false);
      expect(toggle.classList.contains("hidden")).toBe(true);
      expect(toggle.getAttribute("aria-expanded")).toBe("false");
      items.forEach((item) => expect(item.classList.contains("hidden")).toBe(false));
    });

    it("collapses items when not expanded", async () => {
      mediaQuery.matches = false;
      buildDom({ itemsCount: 4, desktopCount: 5, mobileCount: 2 });

      await connectController();

      const items = element.querySelectorAll("[data-participants-item]");

      expect(items[0].classList.contains("hidden")).toBe(false);
      expect(items[1].classList.contains("hidden")).toBe(false);
      expect(items[2].classList.contains("hidden")).toBe(true);
      expect(items[3].classList.contains("hidden")).toBe(true);
    });
  });

  describe("toggle and viewport changes", () => {
    it("resets expanded state when viewport shows all items", async () => {
      mediaQuery.matches = false;
      buildDom({ itemsCount: 4, desktopCount: 5, mobileCount: 2 });

      await connectController();

      const toggle = element.querySelector("[data-participants-toggle]");
      controller.toggle();

      expect(controller.expanded).toBe(true);
      expect(toggle.getAttribute("aria-expanded")).toBe("true");

      mediaQuery.matches = true;
      controller.refreshOnChange();

      expect(controller.expanded).toBe(false);
      expect(toggle.classList.contains("hidden")).toBe(true);
      expect(toggle.getAttribute("aria-expanded")).toBe("false");
    });
  });
});
