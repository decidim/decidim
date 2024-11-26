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
    $("[data-arrow-up]").on("click", this._onClickUpArrow);
    $("[data-arrow-down]").on("click", this._onClickDownArrow);
  }

  unbindArrows() {
    $("[data-arrow-up]").off("click", this._onClickUpArrow);
    $("[data-arrow-down]").off("click", this._onClickDownArrow);
  }

  _onClickDownArrow(event) {
    event.preventDefault();

    const $target = $(event.currentTarget);
    const $assembly = $target.closest("[data-assembly-id]");

    $target.toggleClass("hidden");
    $assembly.find("[data-arrow-up]").toggleClass("hidden");
  }

  _onClickUpArrow(event) {
    event.preventDefault();

    const $target = $(event.currentTarget);
    const $assembly = $target.closest("[data-assembly-id]");
    const parentLevel = $assembly.data("level");

    $target.toggleClass("hidden");
    $assembly.find("[data-arrow-down]").toggleClass("hidden");

    // iterate over all tr elements after the current tr element
    $assembly.nextAll("tr").each((index, element) => {
      const currentLevel = $(element).data("level");

      if (currentLevel > parentLevel) {
        $(element).remove();
      }
    });
  }
}

window.Decidim.AdminAssembliesListComponent = AdminAssembliesListComponent;
const component = new AdminAssembliesListComponent();

component.run();
