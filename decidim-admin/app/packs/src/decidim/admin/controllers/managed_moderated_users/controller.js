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

      const selectAll = this.element.querySelector("#moderated_users_bulk");
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

    window.selectedModeratedUsersCount = () => this.selectedModeratedUsersCount();
    window.selectedModeratedUsersCountUpdate = () => this.selectedModeratedUsersCountUpdate();
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

    const selectAll = this.element.querySelector("#moderated_users_bulk");
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

    Reflect.deleteProperty(window, "selectedModeratedUsersCount");
    Reflect.deleteProperty(window, "selectedModeratedUsersCountUpdate");
    Reflect.deleteProperty(window, "showBulkActionsButton");
    Reflect.deleteProperty(window, "hideBulkActionsButton");
    Reflect.deleteProperty(window, "showOtherActionsButtons");
    Reflect.deleteProperty(window, "hideOtherActionsButtons");
    Reflect.deleteProperty(window, "hideBulkActionForms");
  }

  selectedModeratedUsersCount() {
    return this.element.querySelectorAll(".table-list .js-check-all-moderated_users:checked").length;
  }

  selectedModeratedUsersCountUpdate() {
    const selectedModeratedUsers = this.selectedModeratedUsersCount();

    const countElement = this.element.querySelector("#js-selected-moderated_users-count");
    const blockActions = this.element.querySelector("#js-block-moderated_users-actions");
    const unblockActions = this.element.querySelector("#js-unblock-moderated_users-actions");
    const unreportActions = this.element.querySelector("#js-unreport-moderated_users-actions");

    if (selectedModeratedUsers === 0) {
      if (countElement) {
        countElement.textContent = "";
      }
      if (blockActions) {
        blockActions.classList.add("hide");
      }
      if (unblockActions) {
        unblockActions.classList.add("hide");
      }
      if (unreportActions) {
        unreportActions.classList.add("hide");
      }
    } else if (countElement) {
      countElement.textContent = selectedModeratedUsers;
    }
  }

  showBulkActionsButton() {
    if (this.selectedModeratedUsersCount() > 0) {
      const btn = this.element.querySelector("#js-bulk-actions-button");
      if (btn) {
        btn.classList.remove("hide");
      }
    }
  }

  hideBulkActionsButton(force = false) {
    const bulkActionsButton = this.element.querySelector("#js-bulk-actions-button");
    const bulkActionsDropdown = this.element.querySelector("#js-bulk-actions-dropdown");

    if (this.selectedModeratedUsersCount() === 0 || force) {
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
    const checkboxes = this.element.querySelectorAll(".js-check-all-moderated_users");

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

    this.selectedModeratedUsersCountUpdate();
  }

  _onTableListChange(event) {
    if (!event.target.matches(".js-check-all-moderated_users")) {
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

    const allCheckboxes = Array.from(this.element.querySelectorAll(".js-check-all-moderated_users")).filter((checkboxItem) => checkboxItem.offsetParent !== null);
    const checkedCheckboxes = Array.from(this.element.querySelectorAll(".js-check-all-moderated_users:checked")).filter((checkboxItem) => checkboxItem.offsetParent !== null);

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

    this.element.querySelectorAll(`.js-moderated_user-id-${moderationId}`).forEach((input) => {
      input.checked = checked;
    });
    this.selectedModeratedUsersCountUpdate();
  }

  _onCancelBulkAction() {
    this.hideBulkActionForms();
    this.showBulkActionsButton();
    this.showOtherActionsButtons();
  }
}
