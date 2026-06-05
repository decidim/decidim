/* eslint max-lines: ["error", 650] */
/* global global, jest */
import FormFilterController from "src/decidim/controllers/form_filter/controller";
import { Application } from "@hotwired/stimulus";
import delayed from "src/decidim/refactor/moved/delayed";
import CheckBoxesTree from "src/decidim/refactor/moved/check_boxes_tree";
import { registerCallback, unregisterCallback, pushState, replaceState, state } from "src/decidim/refactor/moved/history";

// Mock dependencies
jest.mock("src/decidim/refactor/moved/delayed");
jest.mock("src/decidim/refactor/moved/check_boxes_tree");
jest.mock("src/decidim/refactor/moved/history");

// Mock Rails global
global.Rails = {
  fire: jest.fn()
};

describe("FormFilterController - Initiative Filters", () => {
  let application = null;
  let controller = null;
  let element = null;
  let mockCheckBoxesTree = null;

  beforeEach(() => {
    // Setup DOM with the provided HTML structure
    document.body.innerHTML = `
      <form class="new_filter self-stretch"
            data-filters=""
            data-controller="form-filter"
            action="/initiatives"
            accept-charset="UTF-8"
            data-remote="true"
            method="get"
            id="accordion-form"
            data-component="accordion"
            role="presentation">

        <button id="dropdown-trigger-filters"
                data-controller="dropdown"
                data-target="dropdown-menu-filters"
                data-open-md="true"
                aria-expanded="false"
                aria-haspopup="true"
                aria-controls="dropdown-menu-filters">
          <span>Filter and search</span>
        </button>

        <div id="dropdown-menu-filters"
             aria-hidden="true"
             role="menu"
             aria-labelledby="dropdown-trigger-filters"
             tabindex="-1">

          <a class="filter-skip" role="menuitem" href="#initiatives">Skip to results</a>

          <p id="filter-help-text" class="filter-help" role="menuitem" aria-disabled="true">
            The form below filters the search results dynamically when the search conditions are changed.
          </p>

          <!-- Search Input -->
          <div class="filter-search filter-container" role="menuitem">
            <input placeholder="Search"
                   title="Search among Initiatives"
                   aria-label="Search among Initiatives"
                   aria-describedby="filter-help-text"
                   type="search"
                   value=""
                   name="filter[search_text_cont]"
                   id="filters_search_input">
            <button type="submit" aria-label="Search among Initiatives">
              <svg width="1em" height="1em" role="img" aria-hidden="true">
                <use href="/decidim-packs/media/images/remixicon.symbol.svg#ri-search-line"></use>
              </svg>
            </button>
          </div>

          <!-- Status Filter -->
          <div class="filter-container" role="menuitem">
            <button id="trigger-menu-state"
                    data-controls="panel-dropdown-menu-state"
                    data-open="true"
                    data-open-md="true"
                    role="button"
                    tabindex="0"
                    aria-controls="panel-dropdown-menu-state"
                    aria-expanded="true"
                    aria-disabled="false">
              <span>Status</span>
            </button>

            <div id="panel-dropdown-menu-state"
                 role="region"
                 tabindex="-1"
                 aria-labelledby="trigger-menu-state"
                 aria-hidden="false">

              <input type="hidden"
                     name="filter[with_any_state][]"
                     id="filter_with_any_state_all"
                     value=""
                     autocomplete="off">

              <!-- All Status -->
              <div class="filter">
                <label for="with_any_state_all" data-global-checkbox="">
                  <input class="reset-defaults"
                         data-checkboxes-tree="with_any_state_state_"
                         id="with_any_state_all"
                         value=""
                         type="checkbox"
                         name="filter[with_any_state][]">
                  <span>All</span>
                </label>
              </div>

              <!-- Open Status -->
              <div class="filter">
                <label data-children-checkbox="with_any_state_state_" for="with_any_state_open">
                  <input class="reset-defaults ignore-filter"
                         id="with_any_state_open"
                         value="open"
                         type="checkbox"
                         name="filter[with_any_state][]">
                  <span>Open</span>
                </label>
              </div>

              <!-- Closed Status (with nested options) -->
              <div class="filter">
                <label data-children-checkbox="with_any_state_state_" for="with_any_state_closed">
                  <input class="reset-defaults ignore-filter"
                         data-checkboxes-tree="with_any_state_state_closed"
                         id="with_any_state_closed"
                         value="closed"
                         type="checkbox"
                         checked="checked"
                         name="filter[with_any_state][]">
                  <span>Closed</span>
                </label>

                <button id="dropdown-trigger-closed-substates"
                        data-controls="panel-dropdown-menu-closed"
                        aria-labelledby="dropdown-title-closed"
                        role="button"
                        tabindex="0"
                        aria-controls="panel-dropdown-menu-closed"
                        aria-expanded="false"
                        aria-disabled="false">
                </button>
              </div>

              <!-- Nested Closed Substates -->
              <div id="panel-dropdown-menu-closed"
                   role="region"
                   tabindex="-1"
                   aria-labelledby="dropdown-trigger-closed-substates"
                   aria-hidden="true">

                <div class="filter">
                  <label data-children-checkbox="with_any_state_state_closed" for="with_any_state_accepted">
                    <input class="reset-defaults ignore-filter"
                           id="with_any_state_accepted"
                           value="accepted"
                           type="checkbox"
                           name="filter[with_any_state][]">
                    <span>Enough signatures</span>
                  </label>
                </div>

                <div class="filter">
                  <label data-children-checkbox="with_any_state_state_closed" for="with_any_state_rejected">
                    <input class="reset-defaults ignore-filter"
                           id="with_any_state_rejected"
                           value="rejected"
                           type="checkbox"
                           name="filter[with_any_state][]">
                    <span>Not enough signatures</span>
                  </label>
                </div>
              </div>

              <!-- Answered Status -->
              <div class="filter">
                <label data-children-checkbox="with_any_state_state_" for="with_any_state_answered">
                  <input class="reset-defaults ignore-filter"
                         id="with_any_state_answered"
                         value="answered"
                         type="checkbox"
                         name="filter[with_any_state][]">
                  <span>Answered</span>
                </label>
              </div>
            </div>
          </div>

          <!-- Scope Filter -->
          <div class="filter-container" role="menuitem">
            <button id="trigger-menu-scope"
                    data-controls="panel-dropdown-menu-scope"
                    data-open="true"
                    data-open-md="true"
                    role="button"
                    tabindex="0"
                    aria-controls="panel-dropdown-menu-scope"
                    aria-expanded="true"
                    aria-disabled="false">
              <span>Scope</span>
            </button>

            <div id="panel-dropdown-menu-scope"
                 role="region"
                 tabindex="-1"
                 aria-labelledby="trigger-menu-scope"
                 aria-hidden="false">

              <input type="hidden"
                     name="filter[with_any_scope][]"
                     id="filter_with_any_scope_all"
                     value=""
                     autocomplete="off">

              <!-- All Scopes -->
              <div class="filter">
                <label for="with_any_scope_all" data-global-checkbox="">
                  <input class="reset-defaults"
                         data-checkboxes-tree="with_any_scope_scope_"
                         id="with_any_scope_all"
                         value=""
                         type="checkbox"
                         name="filter[with_any_scope][]">
                  <span>All</span>
                </label>
              </div>

              <!-- Global Scope -->
              <div class="filter">
                <label data-children-checkbox="with_any_scope_scope_" for="with_any_scope_global">
                  <input class="reset-defaults ignore-filter"
                         id="with_any_scope_global"
                         value="global"
                         type="checkbox"
                         name="filter[with_any_scope][]">
                  <span>Global scope</span>
                </label>
              </div>

              <!-- Test Scope -->
              <div class="filter">
                <label data-children-checkbox="with_any_scope_scope_" for="with_any_scope_1">
                  <input class="reset-defaults ignore-filter"
                         data-checkboxes-tree="with_any_scope_scope_1"
                         id="with_any_scope_1"
                         value="1"
                         type="checkbox"
                         name="filter[with_any_scope][]">
                  <span>Test</span>
                </label>
              </div>
            </div>
          </div>

          <!-- Area Filter -->
          <div class="filter-container" role="menuitem">
            <button id="trigger-menu-area"
                    data-controls="panel-dropdown-menu-area"
                    data-open="true"
                    data-open-md="true"
                    role="button"
                    tabindex="0"
                    aria-controls="panel-dropdown-menu-area"
                    aria-expanded="true"
                    aria-disabled="false">
              <span>Area</span>
            </button>

            <div id="panel-dropdown-menu-area"
                 role="region"
                 tabindex="-1"
                 aria-labelledby="trigger-menu-area"
                 aria-hidden="false">

              <input type="hidden"
                     name="filter[with_any_area][]"
                     id="filter_with_any_area_all"
                     value=""
                     autocomplete="off">

              <!-- All Areas -->
              <div class="filter">
                <label for="with_any_area_all" data-global-checkbox="">
                  <input class="reset-defaults"
                         data-checkboxes-tree="with_any_area_area_"
                         id="with_any_area_all"
                         value=""
                         type="checkbox"
                         name="filter[with_any_area][]">
                  <span>All</span>
                </label>
              </div>

              <!-- Sectorial Area -->
              <div class="filter">
                <label data-children-checkbox="with_any_area_area_" for="with_any_area_2">
                  <input class="reset-defaults ignore-filter"
                         data-checkboxes-tree="with_any_area_area_2"
                         id="with_any_area_2"
                         value="2"
                         type="checkbox"
                         name="filter[with_any_area][]">
                  <span>sectorials</span>
                </label>
              </div>

              <!-- Territorial Area -->
              <div class="filter">
                <label data-children-checkbox="with_any_area_area_" for="with_any_area_1">
                  <input class="reset-defaults ignore-filter"
                         data-checkboxes-tree="with_any_area_area_1"
                         id="with_any_area_1"
                         value="1"
                         type="checkbox"
                         name="filter[with_any_area][]">
                  <span>territorial</span>
                </label>
              </div>
            </div>
          </div>

          <!-- Hidden Order Input -->
          <input type="hidden"
                 name="order"
                 value="random"
                 class="order_filter"
                 autocomplete="off">
        </div>
      </form>

      <main id="main-content">
        <div id="initiatives">Results content</div>
      </main>
    `;

    global.window = global.window || {};
    window.location.href = "https://decidim.dev/";

    global.window.Decidim = {
      PopStateHandler: true
    };

    element = document.getElementById("accordion-form");

    // Mock CheckBoxesTree
    mockCheckBoxesTree = {
      setContainerForm: jest.fn(),
      updateChecked: jest.fn()
    };
    CheckBoxesTree.mockImplementation(() => mockCheckBoxesTree);

    // Mock delayed function
    delayed.mockImplementation((context, fn) => fn);

    // Mock history functions
    state.mockReturnValue({});
    registerCallback.mockImplementation(() => {});
    unregisterCallback.mockImplementation(() => {});
    pushState.mockImplementation(() => {});
    replaceState.mockImplementation(() => {});

    // Setup Stimulus application
    application = Application.start();
    application.register("form-filter", FormFilterController);

    // Mock window location
    Reflect.defineProperty(window, "location", {
      value: {
        origin: "http://localhost",
        pathname: "/initiatives",
        search: "?filter[with_any_state][]=closed",
        hash: ""
      },
      writable: true
    });

    // Mock sessionStorage
    Reflect.defineProperty(window, "sessionStorage", {
      value: {
        setItem: jest.fn(),
        getItem: jest.fn(),
        removeItem: jest.fn()
      },
      writable: true
    });

    // Connect controller
    // Wait for the controller to be connected
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "form-filter");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    jest.clearAllMocks();
    document.body.innerHTML = "";
  });

  describe("initialization", () => {
    it("connects successfully with initiatives form", () => {
      expect(controller).toBeDefined();
      expect(controller.element).toBe(element);
      expect(controller.element.action).toBe("https://decidim.dev/initiatives");
    });

    it("initializes with correct form ID", () => {
      expect(controller.id).toBe("accordion-form");
    });

    it("initializes CheckBoxesTree for hierarchical filters", () => {
      controller.connect();
      expect(CheckBoxesTree).toHaveBeenCalled();
      expect(mockCheckBoxesTree.setContainerForm).toHaveBeenCalledWith(controller.element);
    });
  });

  describe("search functionality", () => {
    it("handles search input changes", () => {
      const spy = jest.spyOn(controller, "_onFormChange");
      const searchInput = element.querySelector("#filters_search_input");
      const submitButton = element.querySelector('button[type="submit"]');

      controller.connect();

      searchInput.value = "climate change";
      searchInput.dispatchEvent(new Event("change", { bubbles: true }));

      submitButton.dispatchEvent(new Event("click", {bubbles: true}))
      expect(spy).toHaveBeenCalled();
    });

    it("includes search text in form data", () => {
      const searchInput = element.querySelector("#filters_search_input");
      searchInput.value = "environmental initiative";

      const [path] = controller._currentStateAndPath();

      expect(path).toContain("filter%5Bsearch_text_cont%5D=environmental+initiative");
    });
  });

  describe("status filter functionality", () => {
    it("handles status filter changes", () => {
      const spy = jest.spyOn(controller, "_onFormChange");
      const openCheckbox = element.querySelector("#with_any_state_open");

      controller.connect();


      openCheckbox.checked = true;
      openCheckbox.dispatchEvent(new Event("change", { bubbles: true }));

      expect(spy).toHaveBeenCalled();
    });

    it("excludes ignore-filter checkboxes from form data", () => {
      // has ignore-filter class
      const openCheckbox = element.querySelector("#with_any_state_open");
      // does not have ignore-filter class
      const allCheckbox = element.querySelector("#with_any_state_all");

      openCheckbox.checked = true;
      allCheckbox.checked = true;

      const [path] = controller._currentStateAndPath();

      // Should not include the ignore-filter checkbox
      expect(path).not.toContain("filter%5Bwith_any_state%5D%5B%5D=open");
      // Should include the non-ignore-filter checkbox
      expect(path).toContain("filter%5Bwith_any_state%5D%5B%5D=");
    });

    it("handles nested status options correctly", () => {
      const closedCheckbox = element.querySelector("#with_any_state_closed");
      const acceptedCheckbox = element.querySelector("#with_any_state_accepted");

      closedCheckbox.checked = true;
      acceptedCheckbox.checked = true;

      expect(closedCheckbox.dataset.checkboxesTree).toBe("with_any_state_state_closed");
      expect(acceptedCheckbox.closest('[data-children-checkbox="with_any_state_state_closed"]')).toBeTruthy();
    });
  });

  describe("scope filter functionality", () => {
    it("handles scope filter selection", () => {
      const globalScopeCheckbox = element.querySelector("#with_any_scope_global");
      const lakeScopeCheckbox = element.querySelector("#with_any_scope_1");

      globalScopeCheckbox.checked = true;
      lakeScopeCheckbox.checked = true;

      // Verify the checkboxes have the correct hierarchical structure
      expect(globalScopeCheckbox.closest('[data-children-checkbox="with_any_scope_scope_"]')).toBeTruthy();
      expect(lakeScopeCheckbox.closest('[data-children-checkbox="with_any_scope_scope_"]')).toBeTruthy();
    });

    it("maintains scope filter hierarchy with CheckBoxesTree", () => {
      const allScopeCheckbox = element.querySelector("#with_any_scope_all");

      expect(allScopeCheckbox.dataset.checkboxesTree).toBe("with_any_scope_scope_");
      expect(allScopeCheckbox.closest("[data-global-checkbox]")).toBeTruthy();
    });
  });

  describe("area filter functionality", () => {
    it("handles area filter selection", () => {
      const sectorialAreaCheckbox = element.querySelector("#with_any_area_2");
      const territorialAreaCheckbox = element.querySelector("#with_any_area_1");

      sectorialAreaCheckbox.checked = true;
      territorialAreaCheckbox.checked = true;

      expect(sectorialAreaCheckbox.dataset.checkboxesTree).toBe("with_any_area_area_2");
      expect(territorialAreaCheckbox.dataset.checkboxesTree).toBe("with_any_area_area_1");
    });
  });

  describe("location parsing with initiative filters", () => {
    beforeEach(() => {
      window.location.search = "?filter[search_text_cont]=environment&filter[with_any_state][]=open&filter[with_any_state][]=closed&filter[with_any_scope][]=global&order=created_at";
    });

    it("correctly parses initiative-specific filter values", () => {
      const filterValues = controller._parseLocationFilterValues();

      expect(filterValues).toEqual({
        // eslint-disable-next-line camelcase
        search_text_cont: "environment",
        // eslint-disable-next-line camelcase
        with_any_state: ["open", "closed"],
        // eslint-disable-next-line camelcase
        with_any_scope: ["global"]
      });
    });
  });

  describe("form state restoration", () => {
    it("restores form state from URL parameters", () => {
      jest.spyOn(controller, "_parseLocationFilterValues").mockReturnValue({
        // eslint-disable-next-line camelcase
        search_text_cont: "civic initiative",
        // eslint-disable-next-line camelcase
        with_any_state: ["open", "answered"],
        // eslint-disable-next-line camelcase
        with_any_scope: ["1", "global"]
      });
      jest.spyOn(controller, "_parseLocationOrderValue").mockReturnValue("recent");

      controller.popStateSubmitter = true;
      controller._onPopState();

      const searchInput = element.querySelector("#filters_search_input");
      expect(searchInput.value).toBe("civic initiative");

      expect(mockCheckBoxesTree.updateChecked).toHaveBeenCalledWith(
        expect.any(Object),
        ["open", "answered"]
      );

      expect(Rails.fire).toHaveBeenCalledWith(element, "submit");
    });
  });

  describe("form clearing functionality", () => {
    it("clears all filter checkboxes", () => {
      // Set some checkboxes
      const openCheckbox = element.querySelector("#with_any_state_open");
      const closedCheckbox = element.querySelector("#with_any_state_closed");
      const globalScopeCheckbox = element.querySelector("#with_any_scope_global");

      openCheckbox.checked = true;
      closedCheckbox.checked = true;
      globalScopeCheckbox.checked = true;

      controller._clearForm();

      expect(openCheckbox.checked).toBe(false);
      expect(closedCheckbox.checked).toBe(false);
      expect(globalScopeCheckbox.checked).toBe(false);
    });
  });

  describe("form submission with initiative data", () => {
    it("generates correct URL for initiative filters", () => {
      const searchInput = element.querySelector("#filters_search_input");
      const allStatusCheckbox = element.querySelector("#with_any_state_all");
      const allScopeCheckbox = element.querySelector("#with_any_scope_all");

      searchInput.value = "environmental protection";
      allStatusCheckbox.checked = true;
      allScopeCheckbox.checked = true;

      const [path] = controller._currentStateAndPath();

      expect(path).toContain("/initiatives?");
      expect(path).toContain("filter%5Bsearch_text_cont%5D=environmental+protection");
      expect(path).toContain("filter%5Bwith_any_state%5D");
      expect(path).toContain("filter%5Bwith_any_scope%5D");
      expect(path).toContain("order=random");
    });
  });

  describe("accessibility features", () => {
    it("maintains proper ARIA attributes", () => {
      const filterDropdown = element.querySelector("#dropdown-menu-filters");
      const searchInput = element.querySelector("#filters_search_input");

      expect(filterDropdown.getAttribute("role")).toBe("menu");
      expect(searchInput.getAttribute("aria-label")).toBe("Search among Initiatives");
      expect(searchInput.getAttribute("aria-describedby")).toBe("filter-help-text");
    });

    it("includes skip link for accessibility", () => {
      const skipLink = element.querySelector(".filter-skip");

      expect(skipLink).toBeTruthy();
      expect(skipLink.getAttribute("href")).toBe("#initiatives");
      expect(skipLink.getAttribute("role")).toBe("menuitem");
    });
  });

  describe("filter help text", () => {
    it("provides accessible help text", () => {
      const helpText = element.querySelector("#filter-help-text");

      expect(helpText).toBeTruthy();
      expect(helpText.getAttribute("role")).toBe("menuitem");
      expect(helpText.getAttribute("aria-disabled")).toBe("true");
      expect(helpText.textContent).toContain("The form below filters the search results dynamically");
    });
  });
});
