/* global jest */

import { Application } from "@hotwired/stimulus"
import SearchFilterDropdownController from "src/decidim/controllers/search_filter_dropdown/controller"

describe("SearchFilterDropdownController", () => {
  let application = null;
  let trigger = null;
  let arrowDown = null;
  let arrowUp = null;
  let list = null;

  beforeEach(() => {
    document.body.innerHTML = `
      <div class="filter-container search__filter" data-controller="search-filter-dropdown">
        <button id="dropdown-trigger-search" aria-expanded="true" data-search-filter-dropdown-target="trigger" data-action="keydown->search-filter-dropdown#toggle">
          <span data-search-filter-dropdown-target="arrowDown" data-action="click->search-filter-dropdown#expand">down</span>
          <span data-search-filter-dropdown-target="arrowUp" data-action="click->search-filter-dropdown#collapse">up</span>
        </button>
        <ul id="dropdown-menu-search" aria-hidden="true" data-search-filter-dropdown-target="list"></ul>
      </div>
    `;

    trigger = document.querySelector("#dropdown-trigger-search");
    arrowDown = document.querySelector("[data-search-filter-dropdown-target='arrowDown']");
    arrowUp = document.querySelector("[data-search-filter-dropdown-target='arrowUp']");
    list = document.querySelector("#dropdown-menu-search");

    application = Application.start();
    application.register("search-filter-dropdown", SearchFilterDropdownController);

    return new Promise((resolve) => {
      setTimeout(resolve, 0);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
  });

  describe("expand", () => {
    it("expands the dropdown after 300ms on arrow-down click", () => {
      jest.useFakeTimers();

      arrowDown.dispatchEvent(new MouseEvent("click", { bubbles: true }));

      expect(trigger.getAttribute("aria-expanded")).toBe("true");
      expect(list.style.display).toBe("");

      jest.advanceTimersByTime(300);

      expect(trigger.getAttribute("aria-expanded")).toBe("true");
      expect(list.style.display).toBe("block");

      jest.useRealTimers();
    });
  });

  describe("collapse", () => {
    it("collapses the dropdown after 300ms on arrow-up click", () => {
      jest.useFakeTimers();

      arrowUp.dispatchEvent(new MouseEvent("click", { bubbles: true }));

      expect(trigger.getAttribute("aria-expanded")).toBe("true");
      expect(list.style.display).toBe("");

      jest.advanceTimersByTime(300);

      expect(trigger.getAttribute("aria-expanded")).toBe("false");
      expect(list.style.display).toBe("none");

      jest.useRealTimers();
    });
  });

  describe("toggle", () => {
    it("collapses on Enter when expanded", () => {
      jest.useFakeTimers();
      trigger.setAttribute("aria-expanded", "true");

      trigger.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 13, bubbles: true }));
      jest.advanceTimersByTime(300);

      expect(trigger.getAttribute("aria-expanded")).toBe("false");
      expect(list.style.display).toBe("none");

      jest.useRealTimers();
    });

    it("collapses on Space when expanded", () => {
      jest.useFakeTimers();
      trigger.setAttribute("aria-expanded", "true");

      trigger.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 32, bubbles: true }));
      jest.advanceTimersByTime(300);

      expect(trigger.getAttribute("aria-expanded")).toBe("false");
      expect(list.style.display).toBe("none");

      jest.useRealTimers();
    });

    it("expands on Enter when collapsed", () => {
      jest.useFakeTimers();
      trigger.setAttribute("aria-expanded", "false");

      trigger.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 13, bubbles: true }));
      jest.advanceTimersByTime(300);

      expect(trigger.getAttribute("aria-expanded")).toBe("true");
      expect(list.style.display).toBe("block");

      jest.useRealTimers();
    });

    it("expands on Space when collapsed", () => {
      jest.useFakeTimers();
      trigger.setAttribute("aria-expanded", "false");

      trigger.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 32, bubbles: true }));
      jest.advanceTimersByTime(300);

      expect(trigger.getAttribute("aria-expanded")).toBe("true");
      expect(list.style.display).toBe("block");

      jest.useRealTimers();
    });

    it("ignores keys other than Enter and Space", () => {
      jest.useFakeTimers();
      trigger.setAttribute("aria-expanded", "true");

      trigger.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 27, bubbles: true }));
      jest.advanceTimersByTime(300);

      expect(trigger.getAttribute("aria-expanded")).toBe("true");
      expect(list.style.display).toBe("");

      jest.useRealTimers();
    });
  });
});
