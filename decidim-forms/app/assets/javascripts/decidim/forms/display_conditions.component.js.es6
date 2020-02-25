/* eslint-disable no-ternary, no-plusplus */

((exports) => {
  class DisplayCondition {
    constructor(options = {}) {
      this.wrapperField = options.wrapperField;
      this.type = options.type;
      this.conditionQuestion = options.conditionQuestion;
      this.answerOption = options.answerOption;
      this.mandatory = options.mandatory;
      this.value = options.value;
      this.onFulfilled = options.onFulfilled;
      this._bindEvent();
    }

    _bindEvent() {
      this._checkCondition();
      this._getInputsToListen().on("change", this._checkCondition.bind(this));
    }

    _getInputValue() {
      const $conditionWrapperField = $(`.question[data-question-id='${this.conditionQuestion}']`);
      const $textInput = $conditionWrapperField.find("textarea, input[type='text']:not([name$=\\[custom_body\\]])");

      if ($textInput.length) {
        return $textInput.val();
      }

      let multipleInput = [];

      $conditionWrapperField.find(".radio-button-collection, .check-box-collection").find(".collection-input").each((idx, el) => {
        const $label = $(el).find("label");
        const checked = !$label.find("input[type='hidden']").is("[disabled]");

        if (checked) {
          const $textField = $(el).find("input[name$=\\[custom_body\\]]");
          const text = $textField.val();
          const value = $label.find("input:not([type='hidden'])").val();
          const id = $label.find("input[type='hidden']").val();

          multipleInput.push({ id, value, text });
        }
      });

      return multipleInput;
    }

    _getInputsToListen() {
      const $conditionWrapperField = $(`.question[data-question-id='${this.conditionQuestion}']`);
      const $textInput = $conditionWrapperField.find("textarea, input[type='text']:not([name$=\\[custom_body\\]])");

      $conditionWrapperField.attr("style", "background: #ccffaa");

      if ($textInput.length) {
        return $textInput;
      }

      return $conditionWrapperField.find(".collection-input").find("input:not([type='hidden'])");
    }

    _checkCondition() {
      const value = this._getInputValue();
      const simpleValue = typeof (value) !== "object";
      let fulfilled = false;

      switch (this.type) {
      case "answered":
        if (simpleValue ? Boolean(value) : Boolean(value.some((it) => it.value))) {
          fulfilled = true;
        }
        break;
      case "not_answered":
        if (simpleValue ? !value : !value.some((it) => it.value)) {
          fulfilled = true;
        }
        break;
      case "equal":
        fulfilled = value.length ? value.some((it) => it.id === this.answerOption) : false;
        break;
      case "not_equal":
        fulfilled = value.length ? value.every((it) => it.id !== this.answerOption) : false;
        break;
      case "match":
        const regexp = new RegExp(this.value, "i");
        const match = simpleValue ? value.match(regexp) : value.some((it) => (it.text ? it.text.match(regexp) : it.value.match(regexp)));
        fulfilled = Boolean(match);
        break;
      }

      this.onFulfilled(fulfilled);
    }
  }

  class DisplayConditionsComponent {
    constructor(options = {}) {
      this.wrapperField = options.wrapperField;
      this.conditions = {};
      this.showCount = 0;
      this._initializeConditions();
    }

    _initializeConditions() {
      const $conditionElements = this.wrapperField.find(".display-condition");

      $conditionElements.each((idx, el) => {
        const $condition = $(el);
        const id = $condition.data("id");
        this.conditions[id] = {};

        this.conditions[id] = new DisplayCondition({
          wrapperField: this.wrapperField,
          type: $condition.data("type"),
          conditionQuestion: $condition.data("condition"),
          answerOption: $condition.data("option"),
          mandatory: $condition.data("mandatory"),
          value: $condition.data("value"),
          onFulfilled: (fulfilled) => {
            this._onFulfilled(id, fulfilled);
          }
        });
      });
    }

    _mustShow() {
      const conditions = Object.values(this.conditions);
      const mandatoryConditions = conditions.filter((condition) => condition.mandatory);
      const nonMandatoryConditions = conditions.filter((condition) => !condition.mandatory);

      if (mandatoryConditions.length) {
        return mandatoryConditions.every((condition) => condition.fulfilled);
      }

      return nonMandatoryConditions.some((condition) => condition.fulfilled);

    }

    _onFulfilled(id, fulfilled) {
      this.conditions[id].fulfilled = fulfilled;

      if (this._mustShow()) {
        this._showQuestion();
      }
      else {
        this._hideQuestion();
      }
    }

    _showQuestion() {
      this.wrapperField.fadeIn();
      this.wrapperField.find("input, textarea").prop("disabled", null);
      this.showCount++;
    }

    _hideQuestion() {
      if (this.showCount) {
        this.wrapperField.fadeOut();
      }
      else {
        this.wrapperField.hide();
      }

      this.wrapperField.find("input, textarea").prop("disabled", "disabled");
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.createDisplayConditions = (options) => {
    return new DisplayConditionsComponent(options);
  };
})(window);
