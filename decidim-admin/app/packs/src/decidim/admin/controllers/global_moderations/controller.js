import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this._boundOnDropdownButtonClick = this._onDropdownButtonClick.bind(this);
    this._boundOnSelectAllChange = this._onSelectAllChange.bind(this);
    this._boundOnTableListChange = this._onTableListChange.bind(this);
    this._boundOnCancelBulkAction = this._onCancelBulkAction.bind(this);

    const forms = this.element.querySelectorAll(".js-bulk-action-form");
    if (forms.length > 0) {
      this.hideBulkActionForms();
      const bulkActionsButton = this.element.querySelector("#js-bulk-actions-button");
      if (bulkActionsButton) {
        bulkActionsButton.classList.add("hide");
      }

      this.element.querySelectorAll("#js-bulk-actions-dropdown li button").forEach((button) => {
        button.addEventListener("click", this._boundOnDropdownButtonClick);
      });

      const selectAll = this.element.querySelector("#moderations_bulk");
      if (selectAll) {
        selectAll.addEventListener("change", this._boundOnSelectAllChange);
      }

      const tableList = this.element.querySelector(".table-list");
      if (tableList) {
        tableList.addEventListener("change", this._boundOnTableListChange);
      }

      this.element.querySelectorAll(".js-cancel-bulk-action").forEach((button) => {
        button.addEventListener("click", this._boundOnCancelBulkAction);
      });
    }

    window.selectedModerationsCount = () => this.selectedModerationsCount();
    window.selectedModerationsCountUpdate = () => this.selectedModerationsCountUpdate();
    window.showBulkActionsButton = () => this.showBulkActionsButton();
    window.hideBulkActionsButton = (force = false) => this.hideBulkActionsButton(force);
    window.showOtherActionsButtons = () => this.showOtherActionsButtons();
    window.hideOtherActionsButtons = () => this.hideOtherActionsButtons();
    window.hideBulkActionForms = () => this.hideBulkActionForms();
  }

  disconnect() {
    this.element.querySelectorAll("#js-bulk-actions-dropdown li button").forEach((button) => {
      button.removeEventListener("click", this._boundOnDropdownButtonClick);
    });

    const selectAll = this.element.querySelector("#moderations_bulk");
    if (selectAll) {
      selectAll.removeEventListener("change", this._boundOnSelectAllChange);
    }

    const tableList = this.element.querySelector(".table-list");
    if (tableList) {
      tableList.removeEventListener("change", this._boundOnTableListChange);
    }

    this.element.querySelectorAll(".js-cancel-bulk-action").forEach((button) => {
      button.removeEventListener("click", this._boundOnCancelBulkAction);
    });

    Reflect.deleteProperty(window, "selectedModerationsCount");
    Reflect.deleteProperty(window, "selectedModerationsCountUpdate");
    Reflect.deleteProperty(window, "showBulkActionsButton");
    Reflect.deleteProperty(window, "hideBulkActionsButton");
    Reflect.deleteProperty(window, "showOtherActionsButtons");
    Reflect.deleteProperty(window, "hideOtherActionsButtons");
    Reflect.deleteProperty(window, "hideBulkActionForms");
  }

  selectedModerationsCount() {
    return this.element.querySelectorAll(".table-list .js-check-all-moderations:checked").length;
  }

  selectedModerationsCountUpdate() {
    const selectedModerations = this.selectedModerationsCount();

    const countElement = this.element.querySelector("#js-selected-moderations-count");
    const hideActions = this.element.querySelector("#js-hide-global-moderations-actions");
    const unhideActions = this.element.querySelector("#js-unhide-global-moderations-actions");
    const unreportActions = this.element.querySelector("#js-unreport-global-moderations-actions");

    if (selectedModerations === 0) {
      if (countElement) {
        countElement.textContent = "";
      }
      if (hideActions) {
        hideActions.classList.add("hide");
      }
      if (unhideActions) {
        unhideActions.classList.add("hide");
      }
      if (unreportActions) {
        unreportActions.classList.add("hide");
      }
    } else if (countElement) {
      countElement.textContent = selectedModerations;
    }
  }

  showBulkActionsButton() {
    if (this.selectedModerationsCount() > 0) {
      const btn = this.element.querySelector("#js-bulk-actions-button");
      if (btn) {
        btn.classList.remove("hide");
      }
    }
  }

  hideBulkActionsButton(force = false) {
    const bulkActionsButton = this.element.querySelector("#js-bulk-actions-button");
    const bulkActionsDropdown = this.element.querySelector("#js-bulk-actions-dropdown");

    if (this.selectedModerationsCount() === 0 || force === true) {
      if (bulkActionsButton) {
        bulkActionsButton.classList.add("hide");
      }
      if (bulkActionsDropdown) {
        bulkActionsDropdown.classList.remove("is-open");
      }
    }
  }

  showOtherActionsButtons() {
    const wrapper = this.element.querySelector("#js-other-actions-wrapper");
    if (wrapper) {
      wrapper.classList.remove("hide");
    }
  }

  hideOtherActionsButtons() {
    const wrapper = this.element.querySelector("#js-other-actions-wrapper");
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
    const bulkActionsDropdown = this.element.querySelector("#js-bulk-actions-dropdown");
    if (bulkActionsDropdown) {
      bulkActionsDropdown.classList.remove("is-open");
    }

    this.hideBulkActionForms();

    const action = event.target.dataset.action;

    if (!action) {
      return;
    }

    const form = this.element.querySelector(`#js-form-${action}`);
    const actionElement = this.element.querySelector(`#js-${action}-actions`);

    if (form) {
      form.addEventListener("submit", this._onFormSubmit.bind(this), {once: true});
      if (actionElement) {
        actionElement.classList.remove("hide");
      }
    } else if (actionElement) {
      actionElement.classList.remove("hide");
    }
    this.hideBulkActionsButton(true);
    this.hideOtherActionsButtons();
  }

  _onFormSubmit() {
    const calloutWrapper = document.querySelector(".layout-content > div[data-callout-wrapper]");
    if (calloutWrapper) {
      calloutWrapper.innerHTML = "";
    }
  }

  _onSelectAllChange(event) {
    const isChecked = event.target.checked;
    const checkboxes = this.element.querySelectorAll(".js-check-all-moderations");

    checkboxes.forEach((checkbox) => {
      checkbox.checked = isChecked;
      const row = checkbox.closest("tr");
      if (row) {
        row.classList.toggle("selected", isChecked);
      }
    });

    if (isChecked) {
      this.showBulkActionsButton();
    } else {
      this.hideBulkActionsButton();
    }

    this.selectedModerationsCountUpdate();
  }

  _onTableListChange(event) {
    if (!event.target.matches(".js-check-all-moderations")) {
      return;
    }

    const checkbox = event.target;
    const moderationId = checkbox.value;
    const checked = checkbox.checked;

    const selectAllCheckbox = this.element.querySelector(".js-check-all");
    if (!checked) {
      if (selectAllCheckbox) {
        selectAllCheckbox.checked = false;
      }
    }

    const allCheckboxes = Array.from(this.element.querySelectorAll(".js-check-all-moderations")).filter((checkboxItem) => checkboxItem.offsetParent !== null);
    const checkedCheckboxes = Array.from(this.element.querySelectorAll(".js-check-all-moderations:checked")).filter((checkboxItem) => checkboxItem.offsetParent !== null);

    if (allCheckboxes.length === checkedCheckboxes.length) {
      if (selectAllCheckbox) {
        selectAllCheckbox.checked = true;
      }
      this.showBulkActionsButton();
    }

    const row = checkbox.closest("tr");
    if (row) {
      row.classList.toggle("selected", checked);
    }

    if (checked) {
      this.showBulkActionsButton();
    } else {
      this.hideBulkActionsButton();
    }

    if (checkedCheckboxes.length === 0) {
      this.hideBulkActionsButton();
    }

    this.element.querySelectorAll(`.js-moderation-id-${moderationId}`).forEach((input) => {
      input.checked = checked;
    });
    this.selectedModerationsCountUpdate();
  }

  _onCancelBulkAction() {
    this.hideBulkActionForms();
    this.showBulkActionsButton();
    this.showOtherActionsButtons();
  }
}
