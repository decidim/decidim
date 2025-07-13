/**
 * Counter class handles the selection of results and updates the counter
 */
class Counter {
  constructor() {
    this.checkboxes = document.querySelectorAll("[data-result-checkbox]");
    this.counterElement = document.querySelector("[data-selected-count]");
  }

  init() {
    if (!this.checkboxes.length) {
      return;
    }

    this.checkboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => this.updateCounter());
    });

    this.updateCounter();
  }

  updateCounter() {
    if (this.counterElement) {
      const count = this.getSelectedItems().length;
      this.counterElement.textContent = count;

      if (count === 0) {
        this.counterElement.classList.add("hide");
      } else {
        this.counterElement.classList.remove("hide");
      }
    }
  }

  getSelectedItems() {
    return Array.from(this.checkboxes).filter((checkbox) => checkbox.checked);
  }
}

export default Counter;
