((exports) => {
  class BudgetRuleTogglerComponent {
    constructor(options = {}) {
      this.ruleCheckboxes = options.ruleCheckboxes;
      this._runAll();
    }

    _runAll() {
      this.ruleCheckboxes.
        each((_i, checkbox) => {
          this._bindEvent(checkbox);
          this.run(checkbox);
        });
    }

    _bindEvent(target) {
      $(target).
        on("change", (event) => {
          this.run(event.target);
        });
    }

    run(target) {
      this.toggleTextInput(target);

      if ($(target).prop("checked")) {
        this.ruleCheckboxes.
          filter(
            (_i, checkbox) => {
              return checkbox !== target;
            }).
          prop("checked", false).
          each(
            (_i, checkbox) => {
              this.toggleTextInput(checkbox);
            });
      }
    }

    toggleTextInput(target) {
      let input = $(target).closest("label").next();
      if ($(target).prop("checked")) {
        input.slideDown();
      } else {
        input.slideUp();
      }
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.BudgetRuleTogglerComponent = BudgetRuleTogglerComponent;
})(window);
