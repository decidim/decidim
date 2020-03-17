((exports) => {
  class BudgetRuleTogglerComponent {
    constructor(options = {}) {
      this.ruleCheckboxes = options.ruleCheckboxes;
      this._runAll();
    }

    _runAll() {
      this.ruleCheckboxes.forEach((el) => {
        this.bindEvent(el);
        this.run(el);
      });
    }

    run(target) {
      let otherCheckboxes = this.ruleCheckboxes.filter(
        (checkbox) => {
          return checkbox !== target;
        });

      if ($(target).prop("checked")) {
        this.toggleInput(target)
        otherCheckboxes.forEach((el) => {
          $(el).prop("checked", false);
          this.toggleInput(el);
        });
      } else {
        this.toggleInput(target);
      }
    }

    toggleInput(target) {
      let input = $(target).closest("label").next();
      if ($(target).prop("checked")) {
        input.slideDown();
      } else {
        input.slideUp();
      }
    }

    bindEvent(target) {
      $(target).on("change", (event) => {
        this.run(`#${event.target.id}`);
      });
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.BudgetRuleTogglerComponent = BudgetRuleTogglerComponent;
})(window);
