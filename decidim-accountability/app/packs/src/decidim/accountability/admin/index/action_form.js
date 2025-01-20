class ActionForm {
  constructor(counter) {
    this.counter = counter;
    this.checkboxes = document.querySelectorAll("[data-result-checkbox]");
    this.idFields = document.querySelectorAll("[data-result-ids-field]");
    this.cancelButtons = document.querySelectorAll("[data-cancel-button]");
  }

  init() {
    this.checkboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => this.onCheckboxChange());
    });

    this.cancelButtons.forEach((button) => {
      button.addEventListener("click", () => this.onCancelButtonClick());
    });

    this.updateResultIdsHiddenField();
  }

  onCheckboxChange() {
    this.updateResultIdsHiddenField();
  }

  onCancelButtonClick() {
    this.hideAllForms();
  }

  hideAllForms() {
    const forms = document.querySelectorAll("[data-action-form]");
    forms.forEach((form) => {
      form.classList.add("hide");
    });
  }

  updateResultIdsHiddenField() {
    const selectedIds = this.counter.getSelectedItems().
      map((checkbox) => checkbox.dataset.resultId);

    this.idFields.forEach((field) => {
      field.value = selectedIds.join(",");
    });
  }
}

export default ActionForm;
