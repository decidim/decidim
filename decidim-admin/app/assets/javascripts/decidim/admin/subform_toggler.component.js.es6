((exports) => {
  class SubformTogglerComponent {
    constructor(options = {}) {
      this.controllerSelect = options.controllerSelect;
      this.subformWrapperClass = options.subformWrapperClass;
      this.globalWrapperSelector = options.globalWrapperSelector;
      this._bindEvent();
      this._runAll();
    }

    _runAll() {
      this.controllerSelect.each((idx, el) => {
        this.run(el);
      });
    }

    run(target) {
      let $target = $(target);
      let subformWrapperClass = this.subformWrapperClass;
      let value = $target.val();

      let $form = $target.parents(this.globalWrapperSelector);
      let $subforms = $form.find(`.${subformWrapperClass}`);
      let $selectedSubform = $subforms.filter(`#${subformWrapperClass}-${value}`)

      $subforms.find("input,textarea,select").prop("disabled", true);
      $subforms.hide();

      $selectedSubform.find("input,textarea,select").prop("disabled", false);
      $selectedSubform.show();
    }

    _bindEvent() {
      this.controllerSelect.on("change", (event) => {
        this.run(event.target);
      });
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.SubformTogglerComponent = SubformTogglerComponent;
})(window);
