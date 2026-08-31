import { Application } from "@hotwired/stimulus";
import BulkActionsController from "src/decidim/admin/controllers/bulk_actions/controller";

/* eslint-disable max-lines */
const waitForConnect = () =>
  new Promise((resolve) => setTimeout(resolve, 50));

const buildDOM = () => {
  document.body.innerHTML = `
    <div
      data-controller="bulk-actions"
      data-bulk-actions-item-selector-value=".js-check-all-resources"
      data-bulk-actions-count-selector-value="#js-selected-resources-count"
      data-bulk-actions-select-all-selector-value=".js-check-all"
      data-bulk-actions-mirror-class-prefix-value="js-resource-id-"
    >
      <input type="checkbox" class="js-check-all">

      <span id="js-selected-resources-count"></span>

      <div id="js-bulk-actions-button" class="hide"></div>

      <div
        id="js-bulk-actions-dropdown"
        class="is-open"
        aria-hidden="false"
      >
        <ul>
          <li>
            <button type="button" data-action="publish">
              Publish
            </button>
          </li>
        </ul>
      </div>

      <div id="js-other-actions-wrapper"></div>

      <form
        id="js-form-publish"
        class="js-bulk-action-form hide"
      ></form>

      <form
        id="form-visible"
        class="js-bulk-action-form"
      ></form>

      <div
        id="js-publish-actions"
        class="js-bulk-action-panel hide"
      ></div>

      <div class="js-bulk-action-panel"></div>

      <button
        type="button"
        class="js-cancel-bulk-action"
      >
        Cancel
      </button>

      <table class="table-list">
        <tbody>
          <tr>
            <td>
              <input
                type="checkbox"
                class="js-check-all-resources"
                value="1"
              >
            </td>
          </tr>
          <tr>
            <td>
              <input
                type="checkbox"
                class="js-check-all-resources"
                value="2"
              >
            </td>
          </tr>
        </tbody>
      </table>

      <input
        type="checkbox"
        class="js-resource-id-1"
      >

      <input
        type="checkbox"
        class="js-resource-id-2"
      >
    </div>
  `;
};

describe("BulkActionsController", () => {
  let application = null;

  const controllerElement = () =>
    document.querySelector(
      "[data-controller='bulk-actions']"
    );

  const itemCheckboxes = () =>
    document.querySelectorAll(
      ".js-check-all-resources"
    );

  const startApplication = async () => {
    application = Application.start();

    application.register(
      "bulk-actions",
      BulkActionsController
    );

    await waitForConnect();
  };

  const makeItemsVisible = () => {
    itemCheckboxes().forEach((checkbox) => {
      Reflect.defineProperty(
        checkbox,
        "offsetParent",
        {
          configurable: true,
          get: () => checkbox.closest("tr")
        }
      );
    });
  };

  const dispatchChange = (element) => {
    element.dispatchEvent(
      new Event("change", { bubbles: true })
    );
  };

  beforeEach(() => {
    buildDOM();
    makeItemsVisible();
  });

  afterEach(() => {
    if (application) {
      application.stop();
      application = null;
    }

    document.body.innerHTML = "";

    Reflect.deleteProperty(
      window,
      "hideBulkActionForms"
    );

    Reflect.deleteProperty(
      window,
      "hideBulkActionsButton"
    );

    Reflect.deleteProperty(
      window,
      "showOtherActionsButtons"
    );

    Reflect.deleteProperty(
      window,
      "selectedResourcesCountUpdate"
    );
  });

  describe("connect()", () => {
    it("sets the initial UI state", async () => {
      await startApplication();

      expect(
        document.getElementById("js-bulk-actions-button").
          classList.contains("hide")
      ).toBe(true);

      expect(
        document.getElementById("js-bulk-actions-dropdown").
          getAttribute("aria-hidden")
      ).toBe("true");

      expect(
        document.getElementById(
          "js-selected-resources-count"
        ).textContent
      ).toBe("");

      document.querySelectorAll(".js-bulk-action-form").
        forEach((form) => {
          expect(
            form.classList.contains("hide")
          ).toBe(true);
        });

      document.querySelectorAll(".js-bulk-action-panel").
        forEach((panel) => {
          expect(
            panel.classList.contains("hide")
          ).toBe(true);
        });
    });

    it("counts items checked before connect", async () => {
      itemCheckboxes()[0].checked = true;

      await startApplication();

      expect(
        document.getElementById(
          "js-selected-resources-count"
        ).textContent
      ).toBe("1");
    });

    it("exposes the legacy bridge functions", async () => {
      await startApplication();

      expect(
        window.hideBulkActionForms
      ).toEqual(expect.any(Function));

      expect(
        window.hideBulkActionsButton
      ).toEqual(expect.any(Function));

      expect(
        window.showOtherActionsButtons
      ).toEqual(expect.any(Function));

      expect(
        window.selectedResourcesCountUpdate
      ).toEqual(expect.any(Function));
    });
  });

  describe("item selection", () => {
    beforeEach(async () => {
      await startApplication();
    });

    it("updates the UI when an item is checked", () => {
      const checkbox = itemCheckboxes()[0];

      checkbox.checked = true;
      dispatchChange(checkbox);

      expect(
        checkbox.
          closest("tr").
          classList.contains("selected")
      ).toBe(true);

      expect(
        document.getElementById(
          "js-selected-resources-count"
        ).textContent
      ).toBe("1");

      expect(
        document.
          getElementById("js-bulk-actions-button").
          classList.contains("hide")
      ).toBe(false);
    });

    it("removes the selection state when unchecked", () => {
      const checkbox = itemCheckboxes()[0];

      checkbox.checked = true;
      dispatchChange(checkbox);

      checkbox.checked = false;
      dispatchChange(checkbox);

      expect(
        checkbox.
          closest("tr").
          classList.contains("selected")
      ).toBe(false);

      expect(
        document.getElementById(
          "js-selected-resources-count"
        ).textContent
      ).toBe("");

      expect(
        document.
          getElementById("js-bulk-actions-button").
          classList.contains("hide")
      ).toBe(true);
    });

    it("synchronizes the mirrored input", () => {
      const checkbox = itemCheckboxes()[0];
      const mirroredInput =
        document.querySelector(".js-resource-id-1");

      checkbox.checked = true;
      dispatchChange(checkbox);

      expect(mirroredInput.checked).toBe(true);

      checkbox.checked = false;
      dispatchChange(checkbox);

      expect(mirroredInput.checked).toBe(false);
    });
  });

  describe("select all", () => {
    beforeEach(async () => {
      await startApplication();
    });

    it("selects all items and updates the UI", () => {
      const selectAll =
        document.querySelector(".js-check-all");

      selectAll.checked = true;
      dispatchChange(selectAll);

      itemCheckboxes().forEach((checkbox) => {
        expect(checkbox.checked).toBe(true);

        expect(
          checkbox.
            closest("tr").
            classList.contains("selected")
        ).toBe(true);
      });

      expect(
        document.getElementById(
          "js-selected-resources-count"
        ).textContent
      ).toBe("2");
    });

    it("unselects all items and hides the button", () => {
      const selectAll =
        document.querySelector(".js-check-all");

      selectAll.checked = true;
      dispatchChange(selectAll);

      selectAll.checked = false;
      dispatchChange(selectAll);

      itemCheckboxes().forEach((checkbox) => {
        expect(checkbox.checked).toBe(false);
      });

      expect(
        document.
          getElementById("js-bulk-actions-button").
          classList.contains("hide")
      ).toBe(true);
    });
  });

  describe("bulk action controls", () => {
    beforeEach(async () => {
      await startApplication();

      itemCheckboxes()[0].checked = true;
      dispatchChange(itemCheckboxes()[0]);
    });

    it("opens the selected action panel", () => {
      document.
        querySelector(
          "#js-bulk-actions-dropdown button"
        ).
        click();

      expect(
        document.
          getElementById("js-publish-actions").
          classList.contains("hide")
      ).toBe(false);

      expect(
        document.
          getElementById("js-bulk-actions-dropdown").
          getAttribute("aria-hidden")
      ).toBe("true");

      expect(
        document.
          getElementById("js-other-actions-wrapper").
          classList.contains("hide")
      ).toBe(true);
    });

    it("restores the controls when canceled", () => {
      document.
        querySelector(
          "#js-bulk-actions-dropdown button"
        ).
        click();

      document.
        querySelector(".js-cancel-bulk-action").
        click();

      expect(
        document.
          getElementById("js-publish-actions").
          classList.contains("hide")
      ).toBe(true);

      expect(
        document.
          getElementById("js-bulk-actions-button").
          classList.contains("hide")
      ).toBe(false);

      expect(
        document.
          getElementById("js-other-actions-wrapper").
          classList.contains("hide")
      ).toBe(false);
    });
  });

  describe("disconnect()", () => {
    it("removes the legacy bridge functions", async () => {
      await startApplication();

      controllerElement().remove();
      await waitForConnect();

      expect(
        window.hideBulkActionForms
      ).toBeUndefined();

      expect(
        window.hideBulkActionsButton
      ).toBeUndefined();

      expect(
        window.showOtherActionsButtons
      ).toBeUndefined();

      expect(
        window.selectedResourcesCountUpdate
      ).toBeUndefined();
    });

    it("removes the select-all listener", async () => {
      await startApplication();

      const root = controllerElement();
      const selectAll =
        document.querySelector(".js-check-all");
      const firstItem = itemCheckboxes()[0];

      root.remove();
      await waitForConnect();

      selectAll.checked = true;
      dispatchChange(selectAll);

      expect(firstItem.checked).toBe(false);
    });
  });
});
/* eslint-enable max-lines */
