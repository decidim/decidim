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

      if ($textInput.length) { return $textInput.val(); }

      let multipleInput = [];

      $conditionWrapperField.find(".radio-button-collection, .check-box-collection").find(".collection-input").each((idx, el) => {
        const $label = $(el).find("label");
        const checked = !$label.find("input[type='hidden']").is("[disabled]");
        console.log(idx + " CHECKED: " + checked);

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

      $conditionWrapperField.attr("style", "background: #ccffaa"); // # TODO: Remove debug line

      if ($textInput.length) { return $textInput; }

      return $conditionWrapperField.find(".collection-input").find("input:not([type='hidden'])");
    }

    _checkCondition() {
      const value = this._getInputValue();
      const simpleValue = typeof (value) != "object";
      let fulfilled = false;

      console.log("VALUE: " + JSON.stringify(value));

      switch (this.type) {
        case "answered":
          if (simpleValue ? !!value : !!value.some((v) => v.value)) {
            fulfilled = true;
          }
          break;
        case "not_answered":
          if (simpleValue ? !value : !value.some((v) => v.value)) {
            fulfilled = true;
          }
          break;
        case "equal":
          fulfilled = value.length ? value.some((v) => v.id == this.answerOption) : false;
          break;
        case "not_equal":
          fulfilled = value.length ? value.every((v) => v.id != this.answerOption) : false;
          break;
        case "match":
          const regexp = new RegExp(this.value, "i");
          const match = simpleValue ? value.match(regexp) : value.some((v) => v.text ? v.text.match(regexp) : v.value.match(regexp));
          fulfilled = !!match;
          break;
      }

      if (fulfilled) { this.onFulfilled(true); }
      else { this.onFulfilled(false); }

      console.log(`Fulfilled ${fulfilled}`); // # TODO: Remove logs 
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
      const mandatoryConditions = conditions.filter((c) => c.mandatory);
      const nonMandatoryConditions = conditions.filter((c) => !c.mandatory);

      return mandatoryConditions.length ? mandatoryConditions.every((c) => c.fulfilled) : nonMandatoryConditions.some((c) => c.fulfilled);
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
      if (this.showCount) this.wrapperField.fadeOut();
      else this.wrapperField.hide();

      this.wrapperField.find("input, textarea").prop("disabled", "disabled");
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.createDisplayConditions = (options) => {
    return new DisplayConditionsComponent(options);
  };
})(window);
