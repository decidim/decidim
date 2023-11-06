/* eslint-disable require-jsdoc */

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

      $field.parents("div.js-collection-input").find(this.dependentInputSelector).prop("disabled", !enabled);
    });
  }

  _bindEvent() {
    this.controllerSelector.on("change", () => {
      this._run();
    });
  }
}

export default function createOptionAttachedInputs(options) {
  return new OptionAttachedInputsComponent(options);
}
