((exports) => {
  class AutoSelectOptionsByTotalItemsComponent {
    constructor(options = {}) {
      this.selectSelector = options.selectSelector;
      this.listSelector = options.listSelector;
    }

    run() {
      const $list = $(this.listSelector);
      const selectSelector = this.selectSelector;

      $(selectSelector).empty();

      for (let idx = 2; idx <= $list.length; idx += 1) {
        $(`<option value="${idx}">${idx}</option>`).appendTo(selectSelector);
      }
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.AutoSelectOptionsByTotalItemsComponent = AutoSelectOptionsByTotalItemsComponent;
})(window);
