((exports) => {
  class FieldDependentInputsComponent {
    constructor(options = {}) {
      this.controllerField = options.controllerField;
      this.wrapperSelector = options.wrapperSelector;
      this.dependentFieldsSelector = options.dependentFieldsSelector;
      this.dependentInputSelector = options.dependentInputSelector;
      this.enablingCondition = options.enablingCondition;
      this._bindEvent();
      this._run();
    }

    _run() {
      const $controllerField = this.controllerField;
      const $dependentFields = $controllerField.parents(this.wrapperSelector).find(this.dependentFieldsSelector);
      const $dependentInputs = $dependentFields.find(this.dependentInputSelector);

      if (this.enablingCondition($controllerField)) {
        $dependentInputs.prop("disabled", false);
        $dependentFields.show();
      } else {
        $dependentInputs.prop("disabled", true);
        $dependentFields.hide();
      }
    }

    _bindEvent() {
      this.controllerField.on("change", () => {
        this._run();
      });
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.FieldDependentInputsComponent = FieldDependentInputsComponent;
  exports.DecidimAdmin.createFieldDependentInputs = (options) => {
    return new FieldDependentInputsComponent(options);
  };
})(window);
