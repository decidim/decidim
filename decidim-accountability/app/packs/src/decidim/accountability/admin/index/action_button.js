class ActionButton {
  constructor(counter) {
    this.counter = counter;
    this.actionButton = document.querySelector("[data-action-button]");
    this.actionForms = document.querySelectorAll("[data-action-form]");
  }

  init() {
    this.counter.checkboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => this.onCheckboxChange());
    });

    this.toggleActionButton();
  }

  onCheckboxChange() {
    this.toggleActionButton();
    this.toggleActionForms();
  }

  toggleActionButton() {
    const selectedIds = this.counter.getSelectedItems();

    if (selectedIds.length > 0) {
      this.actionButton.classList.remove("hide");
    } else {
      this.actionButton.classList.add("hide");
    }
  }

  toggleActionForms() {
    const selectedIds = this.counter.getSelectedItems();

    if (selectedIds.length === 0) {
      this.actionForms.forEach((form) => {
        form.classList.add("hide");
      });
    }
  }
}

export default ActionButton;
