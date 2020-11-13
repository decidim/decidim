((exports) => {
  class SubformMultiTogglerComponent {
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
      let $selectedSubform = $form.find(`#${subformWrapperClass}-${value}`)

      if ($target.prop("checked")) {
        $selectedSubform.find("input,textarea,select").prop("disabled", false);
        $selectedSubform.show();
      } else {
        $selectedSubform.find("input,textarea,select").prop("disabled", true);
        $selectedSubform.hide();
      }
    }

    _bindEvent() {
      this.controllerSelect.on("change", (event) => {
        this.run(event.target);
      });
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.SubformMultiTogglerComponent = SubformMultiTogglerComponent;
})(window);
