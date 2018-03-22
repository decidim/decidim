((exports) => {
  class SelectFieldDependentInputsComponent {
    constructor(options = {}) {
      this.selectField = options.selectField;
      this.wrapperSelector = options.wrapperSelector;
      this.dependentFieldsSelector = options.dependentFieldsSelector;
      this.dependentInputSelector = options.dependentInputSelector;
      this.enablingValues = options.enablingValues;
    }

    run() {
      const $selectField = this.selectField;
      const $dependentFields = $selectField.parents(this.wrapperSelector).find(this.dependentFieldsSelector);
      const $dependentInputs = $dependentFields.find(this.dependentInputSelector);
      const value = $selectField.val();

      if (this.enablingValues.indexOf(value) > -1) {
        $dependentInputs.prop("disabled", false);
        $dependentFields.show();
      } else {
        $dependentInputs.prop("disabled", true);
        $dependentFields.hide();
      }
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.SelectFieldDependentInputsComponent = SelectFieldDependentInputsComponent;
})(window);
