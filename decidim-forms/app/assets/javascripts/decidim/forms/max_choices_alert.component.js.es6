((exports) => {
  class MaxChoicesAlertComponent {
    constructor(options = {}) {
      this.wrapperField = options.wrapperField;
      this.alertElement = options.alertElement;
      this.controllerFieldSelector = options.controllerFieldSelector;
      this.controllerCollectionSelector = options.controllerCollectionSelector;
      this.maxChoices = options.maxChoices;
      this.controllerSelector = this.wrapperField.find(this.controllerFieldSelector);
      this._bindEvent();
      this._run();
    }

    _run() {
      const rows = this.wrapperField.find(this.controllerCollectionSelector);

      let alert = false;

      rows.each((rowIdx, row) => {
        const checked = $(row).find(this.controllerFieldSelector).filter((checkboxIdx, checkbox) => $(checkbox).is(":checked"));

        alert = alert || checked.length > this.maxChoices;
      });

      if (alert) {
        this.alertElement.show();
      }
      else {
        this.alertElement.hide();
      }
    }

    _bindEvent() {
      this.controllerSelector.on("change", () => {
        this._run();
      });
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.createMaxChoicesAlertComponent = (options) => {
    return new MaxChoicesAlertComponent(options);
  };
})(window);
