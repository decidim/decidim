((exports) => {
  class SubformTogglerComponent {
    constructor(options = {}) {
      this.controllerSelect = options.controllerSelect;
      this.subformWrapperClass = options.subformWrapperClass;
      this._bindEvent();
      this.run();
    }

    run() {
      let $controllerSelect = this.controllerSelect;
      let subformWrapperClass = this.subformWrapperClass;
      let value = $controllerSelect.val();

      let $form = $controllerSelect.parents("form");
      let $subforms = $form.find(`.${subformWrapperClass}`);
      let $selectedSubform = $subforms.filter(`#${subformWrapperClass}-${value}`)

      $subforms.find("input,textarea").prop("disabled", true);
      $subforms.hide();

      $selectedSubform.find("input,textarea").prop("disabled", false);
      $selectedSubform.show();
    }

    _bindEvent() {
      this.controllerSelect.on("change", () => {
        this.run();
      });
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.SubformTogglerComponent = SubformTogglerComponent;
})(window);
