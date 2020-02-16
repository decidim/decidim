((exports) => {
  class DisplayCondition {
    constructor(options = {}) {
      this.wrapperField = options.wrapperField;
      this.type = options.type;
      this.conditionQuestion = options.conditionQuestion;
      this.answerOption = options.answerOption;
      this.mandatory = options.mandatory;
      this.value = options.value;
      this._bindEvent();
    }

    _bindEvent() {
      this._checkCondition();
      this._getInputsToListen().on("change", this._checkCondition.bind(this));
    }

    _getInputValue() {
      const $conditionWrapperField = $(`.question[data-question-id='${this.conditionQuestion}']`);
      const $textInput = $conditionWrapperField.find("textarea, input[type='text']");

      if ($textInput.length) { return $textInput.val(); }

      $conditionWrapperField.find(".collection-input").find("label").each((idx, el) => {
        const $label = $(el);
        const checked = $label.find("input:not([type='hidden'])").prop("disabled");

        if (checked) {
          const id = $label.find("input[type='hidden']").val();
          const value = $label.find("input:not([type='hidden'])").val();

          return { id, value };
        }
      });
    }

    _getInputsToListen() {
      const $conditionWrapperField = $(`.question[data-question-id='${this.conditionQuestion}']`);
      $conditionWrapperField.attr("style", "background: #ccffaa");
      const $textInput = $conditionWrapperField.find("textarea, input[type='text']");

      if ($textInput.length) { return $textInput; }

      return $conditionWrapperField.find(".collection-input").find("input[type='hidden']");
    }

    _checkCondition() {
      const value = this._getInputValue();
      const simpleValue = typeof (value) != "object";
      let fulfilled = false;

      switch (this.type) {
        case "answered":
          if (simpleValue ? !!value : value.value) {
            fulfilled = true;
          }
          break;
        case "not_answered":
          if (simpleValue ? !value : !value.value) {
            fulfilled = true;
          }
          break;
        case "equal":
        case "not_equal":
          fulfilled = value.value == this.answerOption;
          break;
        case "match":
          fulfilled = simpleValue ? value.match(this.value) : value.value.match(this.value);
          break;
      }

      if (fulfilled) { this._showQuestion(); }
      else { this._hideQuestion(); }

      console.log(`Fulfilled ${fulfilled}`); // # TODO: Remove logs 
      console.log(this);
      console.log("-----------------------");
    }

    _showQuestion() {
      this.wrapperField.attr("style", "opacity: 1");
      this.wrapperField.find("input, textarea").prop("disabled", null);
    }

    _hideQuestion() {
      this.wrapperField.attr("style", "opacity: 0.5");
      this.wrapperField.find("input, textarea").prop("disabled", "disabled");
    }
  }

  class DisplayConditionsComponent {
    constructor(options = {}) {
      this.wrapperField = options.wrapperField;
      this._initialize();
    }

    _initialize() {
      this.wrapperField.attr("style", "background: #ffaacc");

      const $conditionElements = this.wrapperField.find(".display-condition");
      this.conditions = $conditionElements.map((idx, el) => {
        const $condition = $(el);

        return new DisplayCondition({
          wrapperField: this.wrapperField,
          type: $condition.data("type"),
          conditionQuestion: $condition.data("condition"),
          answerOption: $condition.data("option"),
          mandatory: $condition.data("mandatory"),
          value: $condition.data("value")
        });
      });
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.createDisplayConditions = (options) => {
    return new DisplayConditionsComponent(options);
  };
})(window);
