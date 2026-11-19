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
      element.addEventListener("ajax:error", this._onAjaxError);
    });
  }

  unbindArrows() {
    document.querySelectorAll("[data-arrow-up]").forEach((element) => {
      element.removeEventListener("click", this._onClickUpArrow);
    });
    document.querySelectorAll("[data-arrow-down]").forEach((element) => {
      element.removeEventListener("click", this._onClickDownArrow);
      element.removeEventListener("ajax:error", this._onAjaxError);
    });
  }

  _onClickDownArrow(event) {
    event.preventDefault();

    const target = event.currentTarget;
    const assembly = target.closest("[data-assembly-id]");

    if (assembly.dataset.loading === "true") {
      event.stopImmediatePropagation();
      return;
    }

    assembly.dataset.loading = "true";
    assembly.setAttribute("aria-busy", "true");
    assembly.classList.add("spinner-container");

    const upArrow = assembly.querySelector("[data-arrow-up]");

    target.classList.toggle("hidden");
    upArrow.classList.toggle("hidden");
  }

  _onClickUpArrow(event) {
    event.preventDefault();

    const target = event.currentTarget;
    const assembly = target.closest("[data-assembly-id]");

    if (assembly.dataset.loading === "true") {
      event.stopImmediatePropagation();
      return;
    }

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

  _onAjaxError(event) {
    const assembly = event.currentTarget.closest("[data-assembly-id]");

    if (!assembly) {
      return;
    }

    assembly.classList.remove("spinner-container");
    assembly.removeAttribute("aria-busy");
    assembly.dataset.loading = "false";
  }
}

window.Decidim.AdminAssembliesListComponent = AdminAssembliesListComponent;
const component = new AdminAssembliesListComponent();

component.run();
