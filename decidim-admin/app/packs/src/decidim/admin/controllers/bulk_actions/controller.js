import { Controller } from "@hotwired/stimulus";

/* eslint-disable max-lines */
export default class extends Controller {
  static values = {
    itemSelector: String,
    countSelector: String,
    selectAllSelector: String,
    mirrorClassPrefix: String
  };

  connect() {
    this._boundOnDropdownButtonClick =
      this._onDropdownButtonClick.bind(this);

    this._boundOnSelectAllChange =
      this._onSelectAllChange.bind(this);

    this._boundOnTableListChange =
      this._onTableListChange.bind(this);

    this._boundOnCancelBulkAction =
      this._onCancelBulkAction.bind(this);

    this.hideBulkActionForms();
    this.hideActionElements();
    this.hideBulkActionsButton(true);

    window.hideBulkActionForms = () => {
      this.hideBulkActionForms();
    };

    window.hideBulkActionsButton = (force = false) => {
      this.hideBulkActionsButton(force);
    };

    window.showOtherActionsButtons = () => {
      this.showOtherActionsButtons();
    };

    window.selectedResourcesCountUpdate = () => {
      this.selectedItemsCountUpdate();
    };

    this.dropdownButtons.forEach((button) => {
      button.addEventListener(
        "click",
        this._boundOnDropdownButtonClick
      );
    });

    if (this.selectAllCheckbox) {
      this.selectAllCheckbox.addEventListener(
        "change",
        this._boundOnSelectAllChange
      );
    }

    if (this.tableList) {
      this.tableList.addEventListener(
        "change",
        this._boundOnTableListChange
      );
    }

    this.cancelButtons.forEach((button) => {
      button.addEventListener(
        "click",
        this._boundOnCancelBulkAction
      );
    });

    this.selectedItemsCountUpdate();
  }

  disconnect() {
    Reflect.deleteProperty(window, "hideBulkActionForms");
    Reflect.deleteProperty(window, "hideBulkActionsButton");
    Reflect.deleteProperty(window, "showOtherActionsButtons");
    Reflect.deleteProperty(window, "selectedResourcesCountUpdate");

    this.dropdownButtons.forEach((button) => {
      button.removeEventListener(
        "click",
        this._boundOnDropdownButtonClick
      );
    });

    if (this.selectAllCheckbox) {
      this.selectAllCheckbox.removeEventListener(
        "change",
        this._boundOnSelectAllChange
      );
    }

    if (this.tableList) {
      this.tableList.removeEventListener(
        "change",
        this._boundOnTableListChange
      );
    }

    this.cancelButtons.forEach((button) => {
      button.removeEventListener(
        "click",
        this._boundOnCancelBulkAction
      );
    });
  }

  get itemSelector() {
    return this.itemSelectorValue;
  }

  get countSelector() {
    return this.countSelectorValue;
  }

  get selectAllSelector() {
    return this.selectAllSelectorValue;
  }

  get mirrorClassPrefix() {
    return this.mirrorClassPrefixValue;
  }

  get dropdownButtons() {
    return this.element.querySelectorAll(
      "#js-bulk-actions-dropdown li button[data-action]"
    );
  }

  get selectAllCheckbox() {
    return this.element.querySelector(
      this.selectAllSelector
    );
  }

  get tableList() {
    return this.element.querySelector(".table-list");
  }

  get cancelButtons() {
    return this.element.querySelectorAll(
      ".js-cancel-bulk-action"
    );
  }

  get itemCheckboxes() {
    return this.element.querySelectorAll(
      this.itemSelector
    );
  }

  selectedItemsCount() {
    return this.element.querySelectorAll(
      `.table-list ${this.itemSelector}:checked`
    ).length;
  }

  selectedItemsCountUpdate() {
    const selectedItems = this.selectedItemsCount();

    const countElement = this.element.querySelector(
      this.countSelector
    );

    if (selectedItems === 0) {
      if (countElement) {
        countElement.textContent = "";
      }

      this.hideActionElements();
      return;
    }

    if (countElement) {
      countElement.textContent = selectedItems;
    }
  }

  hideActionElements() {
    this.element.querySelectorAll(
      ".js-bulk-action-panel").forEach(
      (actionElement) => {
        actionElement.classList.add("hide");
      });
  }

  showBulkActionsButton() {
    if (this.selectedItemsCount() === 0) {
      return;
    }

    const bulkActionsButton = this.element.querySelector(
      "#js-bulk-actions-button"
    );

    if (bulkActionsButton) {
      bulkActionsButton.classList.remove("hide");
    }
  }

  hideBulkActionsButton(force = false) {
    const bulkActionsButton = this.element.querySelector(
      "#js-bulk-actions-button"
    );

    const bulkActionsDropdown = this.element.querySelector(
      "#js-bulk-actions-dropdown"
    );

    if (this.selectedItemsCount() === 0 || force === true) {
      if (bulkActionsButton) {
        bulkActionsButton.classList.add("hide");
      }

      if (bulkActionsDropdown) {
        bulkActionsDropdown.classList.remove("is-open");
        bulkActionsDropdown.setAttribute("aria-hidden", "true");
      }
    }
  }

  showOtherActionsButtons() {
    const wrapper = this.element.querySelector(
      "#js-other-actions-wrapper"
    );

    if (wrapper) {
      wrapper.classList.remove("hide");
    }
  }

  hideOtherActionsButtons() {
    const wrapper = this.element.querySelector(
      "#js-other-actions-wrapper"
    );

    if (wrapper) {
      wrapper.classList.add("hide");
    }
  }

  hideBulkActionForms() {
    this.element.querySelectorAll(".js-bulk-action-form").forEach((form) => {
      form.classList.add("hide");
    });
  }

  _onDropdownButtonClick(event) {
    const button = event.currentTarget;
    const action = button.dataset.action;
    const preserveControls =
      button.dataset.bulkActionsPreserveControls === "true";

    const bulkActionsDropdown = this.element.querySelector(
      "#js-bulk-actions-dropdown"
    );

    if (bulkActionsDropdown) {
      bulkActionsDropdown.classList.remove("is-open");
      bulkActionsDropdown.setAttribute(
        "aria-hidden",
        "true"
      );
    }

    this.hideBulkActionForms();
    this.hideActionElements();

    if (!action) {
      return;
    }

    const form = this.element.querySelector(
      `#js-form-${action}`
    );

    const actionElement = this.element.querySelector(
      `#js-${action}-actions`
    );

    if (form) {
      form.addEventListener(
        "submit",
        () => this._onFormSubmit(),
        { once: true }
      );
    }

    if (actionElement) {
      actionElement.classList.remove("hide");
    }

    if (!preserveControls) {
      this.hideBulkActionsButton(true);
      this.hideOtherActionsButtons();
    }
  }

  _onFormSubmit() {
    const calloutWrapper = document.querySelector(
      ".layout-content > div[data-callout-wrapper]"
    );

    if (calloutWrapper) {
      calloutWrapper.innerHTML = "";
    }
  }

  _onSelectAllChange(event) {
    const isChecked = event.currentTarget.checked;

    this.itemCheckboxes.forEach((checkbox) => {
      checkbox.checked = isChecked;

      const row = checkbox.closest("tr");

      if (row) {
        row.classList.toggle("selected", isChecked);
      }

      this._synchronizeMirroredInputs(checkbox);
    });

    if (isChecked) {
      this.showBulkActionsButton();
    } else {
      this.hideBulkActionsButton();
    }

    this.selectedItemsCountUpdate();
  }

  _onTableListChange(event) {
    if (!event.target.matches(this.itemSelector)) {
      return;
    }

    const checkbox = event.target;
    const checked = checkbox.checked;

    const visibleCheckboxes = Array.from(
      this.itemCheckboxes
    ).filter((checkboxItem) => {
      return checkboxItem.offsetParent !== null;
    });

    const visibleCheckedCheckboxes = visibleCheckboxes.filter(
      (checkboxItem) => {
        return checkboxItem.checked;
      }
    );

    if (this.selectAllCheckbox) {
      const allVisibleItemsSelected =
        visibleCheckboxes.length > 0 &&
        visibleCheckboxes.length ===
        visibleCheckedCheckboxes.length;

      this.selectAllCheckbox.checked =
        allVisibleItemsSelected;

      this.selectAllCheckbox.indeterminate =
        visibleCheckedCheckboxes.length > 0 &&
        visibleCheckedCheckboxes.length <
        visibleCheckboxes.length;
    }

    const row = checkbox.closest("tr");

    if (row) {
      row.classList.toggle("selected", checked);
    }

    this._synchronizeMirroredInputs(checkbox);

    if (visibleCheckedCheckboxes.length > 0) {
      this.showBulkActionsButton();
    } else {
      this.hideBulkActionsButton();
    }

    this.selectedItemsCountUpdate();
  }

  /*
   * Synchronize checkbox values with hidden/action form inputs.
   */

  _synchronizeMirroredInputs(checkbox) {
    const itemId = checkbox.value;

    if (!itemId) {
      return;
    }

    const escapedItemId =
      typeof CSS !== "undefined" && CSS.escape
        ? CSS.escape(itemId)
        : itemId;

    this.element.querySelectorAll(
      `.${this.mirrorClassPrefix}${escapedItemId}`
    ).forEach((input) => {
      input.checked = checkbox.checked;
    });
  }

  _onCancelBulkAction() {
    this.hideBulkActionForms();
    this.hideActionElements();
    this.showBulkActionsButton();
    this.showOtherActionsButtons();
  }
}
/* eslint-enable max-lines */
