// = require ./auto_buttons_by_min_items.component
// = require ./auto_select_options_by_total_items.component
// = require ./auto_select_options_from_url.component

((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, AutoButtonsByMinItemsComponent, AutoSelectOptionsByTotalItemsComponent, AutoSelectOptionsFromUrl, createFieldDependentInputs, createDynamicFields, createSortList } = exports.DecidimAdmin;
  const { createQuillEditor } = exports.Decidim;

  const wrapperSelector = ".questionnaire-questions";
  const fieldSelector = ".questionnaire-question";
  const questionTypeSelector = "select[name$=\\[question_type\\]]";
  const answerOptionFieldSelector = ".questionnaire-question-answer-option";
  const answerOptionsWrapperSelector = ".questionnaire-question-answer-options";
  const answerOptionRemoveFieldButtonSelector = ".remove-answer-option";
  const maxChoicesWrapperSelector = ".questionnaire-question-max-choices";

  const displayConditionFieldSelector = ".questionnaire-question-display-condition";
  const displayConditionsWrapperSelector = ".questionnaire-question-display-conditions";
  const displayConditionRemoveFieldButtonSelector = ".remove-display-condition";

  const displayConditionQuestionSelector = "select[name$=\\[decidim_condition_question_id\\]]";
  const displayConditionAnswerOptionSelector = "select[name$=\\[decidim_answer_option_id\\]]";
  const displayConditionTypeSelector = "select[name$=\\[condition_type\\]]";
  const displayConditionDeletedSelector = "input[name$=\\[deleted\\]]";

  const displayConditionValueWrapperSelector = ".questionnaire-question-display-condition-value";
  const displayconditionAnswerOptionWrapperSelector = ".questionnaire-question-display-condition-answer-option";

  const addDisplayConditionButtonSelector = ".add-display-condition";

  const removeDisplayConditionsForFirstQuestion = () => {
    $(fieldSelector).each((idx, el) => {
      const $question = $(el);
      if (idx) {
        $question.find(displayConditionsWrapperSelector).find(displayConditionDeletedSelector).val("false");
        $question.find(displayConditionsWrapperSelector).show();
      }
      else {
        $question.find(displayConditionsWrapperSelector).find(displayConditionDeletedSelector).val("true");
        $question.find(displayConditionsWrapperSelector).hide();
      }
    });
  };

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".questionnaire-question:not(.hidden)",
    hideOnFirstSelector: ".move-up-question",
    hideOnLastSelector: ".move-down-question"
  });

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".questionnaire-question:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);

      autoButtonsByPosition.run();

      removeDisplayConditionsForFirstQuestion();
    }
  });

  const createAutoMaxChoicesByNumberOfAnswerOptions = (fieldId) => {
    return new AutoSelectOptionsByTotalItemsComponent({
      wrapperSelector: fieldSelector,
      selectSelector: `${maxChoicesWrapperSelector} select`,
      listSelector: `#${fieldId} ${answerOptionsWrapperSelector} .questionnaire-question-answer-option:not(.hidden)`
    })
  };

  const createAutoButtonsByMinItemsForAnswerOptions = (fieldId) => {
    return new AutoButtonsByMinItemsComponent({
      wrapperSelector: fieldSelector,
      listSelector: `#${fieldId} ${answerOptionsWrapperSelector} .questionnaire-question-answer-option:not(.hidden)`,
      minItems: 2,
      hideOnMinItemsOrLessSelector: answerOptionRemoveFieldButtonSelector
    })
  };

  const createAutoSelectOptionsFromUrl = ($field) => {
    return new AutoSelectOptionsFromUrl({
      source: $field.find(displayConditionQuestionSelector),
      select: $field.find(displayConditionAnswerOptionSelector),
      sourceToParams: ($element) => { return { id: $element.val() } }
    })
  };

  const createSortableList = () => {
    createSortList(".questionnaire-questions-list:not(.published)", {
      handle: ".question-divider",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => { autoLabelByPosition.run() }
    });
  };

  const createDynamicFieldsForAnswerOptions = (fieldId) => {
    const autoButtons = createAutoButtonsByMinItemsForAnswerOptions(fieldId);
    const autoSelectOptions = createAutoMaxChoicesByNumberOfAnswerOptions(fieldId);

    return createDynamicFields({
      placeholderId: "questionnaire-question-answer-option-id",
      wrapperSelector: `#${fieldId} ${answerOptionsWrapperSelector}`,
      containerSelector: ".questionnaire-question-answer-options-list",
      fieldSelector: answerOptionFieldSelector,
      addFieldButtonSelector: ".add-answer-option",
      removeFieldButtonSelector: answerOptionRemoveFieldButtonSelector,
      onAddField: () => {
        autoButtons.run();
        autoSelectOptions.run();
      },
      onRemoveField: () => {
        autoButtons.run();
        autoSelectOptions.run();
      }
    });
  };

  const dynamicFieldsForAnswerOptions = {};

  const createDynamicFieldsForDisplayConditions = (fieldId) => {
    return createDynamicFields({
      placeholderId: "questionnaire-question-display-condition-id",
      wrapperSelector: `#${fieldId} ${displayConditionsWrapperSelector}`,
      containerSelector: ".questionnaire-question-display-conditions-list",
      fieldSelector: displayConditionFieldSelector,
      addFieldButtonSelector: addDisplayConditionButtonSelector,
      removeFieldButtonSelector: displayConditionRemoveFieldButtonSelector,
      onAddField: ($field) => {
        initializeDisplayConditionField($field);
      },
      onRemoveField: () => {
      }
    });
  };

  const initializeDisplayConditionField = ($field) => {
    const autoSelectByUrl = createAutoSelectOptionsFromUrl($field);
    autoSelectByUrl.run();

    $field.find(displayConditionQuestionSelector).on("change", (event) => {
      onDisplayConditionQuestionChange($field);
    });

    $field.find(displayConditionTypeSelector).on("change", (event) => {
      onDisplayConditionTypeChange($field);
    });

    onDisplayConditionTypeChange($field);
    onDisplayConditionQuestionChange($field);
  }

  const onDisplayConditionQuestionChange = ($field) => {
    const $questionSelector = $field.find(displayConditionQuestionSelector);
    const selectedQuestionType = getSelectedQuestionType($questionSelector[0]);

    const isMultiple = isMultipleChoiceOption(selectedQuestionType);

    let conditionTypes = ["answered", "not_answered"];

    if (isMultiple) {
      conditionTypes.push("equal");
      conditionTypes.push("not_equal");
    }

    conditionTypes.push("match");

    const $conditionTypeSelect = $field.find(displayConditionTypeSelector);

    $conditionTypeSelect.find("option").each((idx, option) => {
      const $option = $(option);
      const value = $option.val();

      if (!value) return;

      $option.show();

      if (conditionTypes.indexOf(value) < 0) {
        $option.hide();
      }
    });

    if (conditionTypes.indexOf($conditionTypeSelect.val()) < 0) {
      $conditionTypeSelect.val(conditionTypes[0]);
    }

    $conditionTypeSelect.trigger("change");
  };

  const onDisplayConditionTypeChange = ($field) => {
    const value = $field.find(displayConditionTypeSelector).val();
    const $valueWrapper = $field.find(displayConditionValueWrapperSelector);
    const $answerOptionWrapper = $field.find(displayconditionAnswerOptionWrapperSelector);

    const $questionSelector = $field.find(displayConditionQuestionSelector);
    const selectedQuestionType = getSelectedQuestionType($questionSelector[0]);

    const isMultiple = isMultipleChoiceOption(selectedQuestionType);

    if (value == "match") { $valueWrapper.show(); }
    else { $valueWrapper.hide(); }

    if (isMultiple && (value == "not_equal" || value == "equal")) { $answerOptionWrapper.show(); }
    else { $answerOptionWrapper.hide(); }
  };

  const dynamicFieldsForDisplayConditions = {};

  const isMultipleChoiceOption = (value) => {
    return value === "single_option" || value === "multiple_option" || value === "sorting"
  };

  const getSelectedQuestionType = (select) => {
    const selectedOption = select.options[select.selectedIndex];
    return $(selectedOption).data("type");
  };

  const setupInitialQuestionAttributes = ($target) => {
    const fieldId = $target.attr("id");
    const $fieldQuestionTypeSelect = $target.find(questionTypeSelector);

    createFieldDependentInputs({
      controllerField: $fieldQuestionTypeSelect,
      wrapperSelector: fieldSelector,
      dependentFieldsSelector: answerOptionsWrapperSelector,
      dependentInputSelector: `${answerOptionFieldSelector} input`,
      enablingCondition: ($field) => {
        return isMultipleChoiceOption($field.val());
      }
    });

    createFieldDependentInputs({
      controllerField: $fieldQuestionTypeSelect,
      wrapperSelector: fieldSelector,
      dependentFieldsSelector: maxChoicesWrapperSelector,
      dependentInputSelector: "select",
      enablingCondition: ($field) => {
        return $field.val() === "multiple_option"
      }
    });

    dynamicFieldsForAnswerOptions[fieldId] = createDynamicFieldsForAnswerOptions(fieldId);
    dynamicFieldsForDisplayConditions[fieldId] = createDynamicFieldsForDisplayConditions(fieldId);
    const dynamicFields = dynamicFieldsForAnswerOptions[fieldId];

    const onQuestionTypeChange = () => {
      if (isMultipleChoiceOption($fieldQuestionTypeSelect.val())) {
        const nOptions = $fieldQuestionTypeSelect.parents(fieldSelector).find(answerOptionFieldSelector).length;

        if (nOptions === 0) {
          dynamicFields._addField();
          dynamicFields._addField();
        }
      }
    };

    $fieldQuestionTypeSelect.on("change", onQuestionTypeChange);

    onQuestionTypeChange();
  }

  const hideDeletedQuestion = ($target) => {
    const inputDeleted = $target.find("input[name$=\\[deleted\\]]").val();

    if (inputDeleted === "true") {
      $target.addClass("hidden");
      $target.hide();
    }
  }

  createDynamicFields({
    placeholderId: "questionnaire-question-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".questionnaire-questions-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-question",
    removeFieldButtonSelector: ".remove-question",
    moveUpFieldButtonSelector: ".move-up-question",
    moveDownFieldButtonSelector: ".move-down-question",
    onAddField: ($field) => {
      setupInitialQuestionAttributes($field);
      createSortableList();

      $field.find(".editor-container").each((idx, el) => {
        createQuillEditor(el);
      });

      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onRemoveField: ($field) => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();

      $field.find(answerOptionRemoveFieldButtonSelector).each((idx, el) => {
        dynamicFieldsForAnswerOptions[$field.attr("id")]._removeField(el);
      });
    },
    onMoveUpField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onMoveDownField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    }
  });

  createSortableList();

  $(fieldSelector).each((idx, el) => {
    const $target = $(el);

    hideDeletedQuestion($target);
    setupInitialQuestionAttributes($target);
  });

  $(displayConditionFieldSelector).each((idx, el) => {
    const $field = $(el);
    initializeDisplayConditionField($field)
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();
})(window);
