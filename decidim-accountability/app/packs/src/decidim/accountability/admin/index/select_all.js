class SelectAll {
  constructor(counter) {
    this.counter = counter;
    this.checkboxes = this.counter.checkboxes;
    this.selectAllButton = document.querySelector("[data-select-all]");
  }

  init() {
    if (this.selectAllButton) {
      this.selectAllButton.addEventListener("click", (event) => this.onSelectAllClick(event));
    }
  }

  onSelectAllClick(event) {
    event.preventDefault();

    const someUnchecked = Array.from(this.checkboxes).some((checkbox) => !checkbox.checked);

    // If some checkboxes are unchecked, check all of them
    // Otherwise, uncheck all checkboxes
    this.checkboxes.forEach((checkbox) => {
      checkbox.checked = someUnchecked;
      // Trigger change event to update other components
      checkbox.dispatchEvent(new Event("change"));
    });
  }
}

export default SelectAll;
