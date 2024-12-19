/* eslint-disable require-jsdoc */

class AdminAssembliesListComponent {
  run() {
    this.rebindArrows();
  }

  rebindArrows() {
    this.unbindArrows();
    this.bindArrows();
  }

  bindArrows() {
    document.querySelectorAll("[data-arrow-up]").forEach((element) => {
      element.addEventListener("click", this._onClickUpArrow);
    });
    document.querySelectorAll("[data-arrow-down]").forEach((element) => {
      element.addEventListener("click", this._onClickDownArrow);
    });
  }

  unbindArrows() {
    document.querySelectorAll("[data-arrow-up]").forEach((element) => {
      element.removeEventListener("click", this._onClickUpArrow);
    });
    document.querySelectorAll("[data-arrow-down]").forEach((element) => {
      element.removeEventListener("click", this._onClickDownArrow);
    });
  }

  _onClickDownArrow(event) {
    event.preventDefault();

    const target = event.currentTarget;
    const assembly = target.closest("[data-assembly-id]");
    const upArrow = assembly.querySelector("[data-arrow-up]");

    target.classList.toggle("hidden");
    upArrow.classList.toggle("hidden");
  }

  _onClickUpArrow(event) {
    event.preventDefault();

    const target = event.currentTarget;
    const assembly = target.closest("[data-assembly-id]");
    const parentLevel = assembly.dataset.level;
    const downArrow = assembly.querySelector("[data-arrow-down]");

    target.classList.toggle("hidden");
    downArrow.classList.toggle("hidden");

    // Get all following tr elements
    let nextElement = assembly.nextElementSibling;
    while (nextElement) {
      const currentLevel = nextElement.dataset.level;
      const nextSibling = nextElement.nextElementSibling;

      if (currentLevel > parentLevel) {
        nextElement.remove();
      } else {
        break;
      }
      nextElement = nextSibling;
    }
  }
}

window.Decidim.AdminAssembliesListComponent = AdminAssembliesListComponent;
const component = new AdminAssembliesListComponent();

component.run();
