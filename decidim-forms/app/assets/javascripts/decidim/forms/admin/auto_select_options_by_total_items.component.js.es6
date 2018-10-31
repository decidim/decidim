((exports) => {
  class AutoSelectOptionsByTotalItemsComponent {
    constructor(options = {}) {
      this.wrapperSelector = options.wrapperSelector;
      this.selectSelector = options.selectSelector;
      this.listSelector = options.listSelector;
    }

    run() {
      const $list = $(this.listSelector);
      const $selectField = $list.parents(this.wrapperSelector).find(this.selectSelector);

      $selectField.find("option").slice(1).remove();

      for (let idx = 2; idx <= $list.length; idx += 1) {
        $(`<option value="${idx}">${idx}</option>`).appendTo($selectField);
      }
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.AutoSelectOptionsByTotalItemsComponent = AutoSelectOptionsByTotalItemsComponent;
})(window);
