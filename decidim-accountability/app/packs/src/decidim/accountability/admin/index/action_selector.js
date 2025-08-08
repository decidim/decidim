class ActionSelector {
  init() {
    this.dropdownElement = document.querySelector("#js-bulk-actions-dropdown");
    const buttons = this.dropdownElement.querySelectorAll("button");

    buttons.forEach((button) => {
      button.addEventListener("click", this.onActionClick.bind(this));
    });
  }

  onActionClick(event) {
    const action = event.target.dataset.action;

    this.closeDropdown();
    this.hideAllForms();
    this.showForm(action);
  }

  closeDropdown() {
    this.dropdownElement.classList.remove("is-open");
  }

  showForm(action) {
    const form = document.querySelector(`[data-action-form="${action}"]`);

    form.classList.remove("hide");
  }

  hideAllForms() {
    const forms = document.querySelectorAll("[data-action-form]");
    forms.forEach((form) => {
      form.classList.add("hide");
    });
  }
}

export default ActionSelector;
