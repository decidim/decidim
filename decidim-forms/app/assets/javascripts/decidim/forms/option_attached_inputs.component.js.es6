((exports) => {
  class OptionAttachedInputsComponent {
    constructor(options = {}) {
      this.wrapperField = options.wrapperField;
      this.controllerFieldSelector = options.controllerFieldSelector;
      this.dependentInputSelector = options.dependentInputSelector;
      this.controllerSelector = this.wrapperField.find(this.controllerFieldSelector);
      this._bindEvent();
      this._run();
    }

    _run() {
      this.controllerSelector.each((idx, el) => {
        const $field = $(el);
        const enabled = $field.is(":checked");

        $field.parents("label").find(this.dependentInputSelector).prop("disabled", !enabled);
      });
    }

    _bindEvent() {
      this.controllerSelector.on("change", () => {
        this._run();
      });
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.createOptionAttachedInputs = (options) => {
    return new OptionAttachedInputsComponent(options);
  };
})(window);
