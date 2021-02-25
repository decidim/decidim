((exports) => {
  class BudgetRuleTogglerComponent {
    constructor(options = {}) {
      this.ruleCheckboxes = options.ruleCheckboxes;
      this._runAll();
    }

    _runAll() {
      this.ruleCheckboxes.each((_i, checkbox) => {
        this._bindEvent(checkbox);
        this.run(checkbox);
      });
    }

    _bindEvent(target) {
      $(target).on("change", (event) => {
        this.run(event.target);
      });
    }

    run(target) {
      this.toggleTextInput(target);

      if ($(target).prop("checked")) {
        this.ruleCheckboxes.filter(
          (_i, checkbox) => {
            return checkbox !== target;
          }).prop("checked", false).each(
          (_i, checkbox) => {
            this.toggleTextInput(checkbox);
          });
      }
    }

    toggleTextInput(target) {
      const container = $(target).closest("div");
      if (container.length < 1) {
        return;
      }
      const containerClassPrefix = container.attr("class").
        replace(/^vote_rule_/, "vote_").
        replace(/_enabled_container$/, "");
      const input = $(`[class^="${containerClassPrefix}"][class$="_container"]`);

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
