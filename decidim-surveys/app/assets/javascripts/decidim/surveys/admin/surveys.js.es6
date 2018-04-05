// = require ./auto_label_by_position.component
// = require ./auto_buttons_by_position.component
// = require ./auto_buttons_by_min_items.component
// = require ./auto_select_options_by_total_items.component
// = require ./dynamic_fields.component
// = require ./field_dependent_inputs.component

((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, AutoButtonsByMinItemsComponent, AutoSelectOptionsByTotalItemsComponent, createFieldDependentInputs, createDynamicFields, createSortList } = exports.DecidimAdmin;
  const { createQuillEditor } = exports.Decidim;

  const wrapperSelector = ".survey-questions";
  const fieldSelector = ".survey-question";
  const questionTypeSelector = "select[name$=\\[question_type\\]]";
  const answerOptionFieldSelector = ".survey-question-answer-option";
  const answerOptionsWrapperSelector = ".survey-question-answer-options";
  const answerOptionRemoveFieldButtonSelector = ".remove-answer-option";
  const maxChoicesWrapperSelector = ".survey-question-max-choices";

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".survey-question:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".survey-question:not(.hidden)",
    hideOnFirstSelector: ".move-up-question",
    hideOnLastSelector: ".move-down-question"
  });

  const createAutoMaxChoicesByNumberOfAnswerOptions = (fieldId) => {
    return new AutoSelectOptionsByTotalItemsComponent({
      wrapperSelector: fieldSelector,
      selectSelector: `${maxChoicesWrapperSelector} select`,
      listSelector: `#${fieldId} ${answerOptionsWrapperSelector} .survey-question-answer-option:not(.hidden)`
    })
  };

  const createAutoButtonsByMinItemsForAnswerOptions = (fieldId) => {
    return new AutoButtonsByMinItemsComponent({
      wrapperSelector: fieldSelector,
      listSelector: `#${fieldId} ${answerOptionsWrapperSelector} .survey-question-answer-option:not(.hidden)`,
      minItems: 2,
      hideOnMinItemsOrLessSelector: answerOptionRemoveFieldButtonSelector
    })
  };

  const createSortableList = () => {
    createSortList(".survey-questions-list:not(.published)", {
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
      placeholderId: "survey-question-answer-option-id",
      wrapperSelector: `#${fieldId} ${answerOptionsWrapperSelector}`,
      containerSelector: ".survey-question-answer-options-list",
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

  const isMultipleChoiceOption = ($selectField) => {
    const value = $selectField.val();

    return value === "single_option" || value === "multiple_option"
  }

  const setupInitialQuestionAttributes = ($target) => {
    const fieldId = $target.attr("id");
    const $fieldQuestionTypeSelect = $target.find(questionTypeSelector);

    createFieldDependentInputs({
      controllerField: $fieldQuestionTypeSelect,
      wrapperSelector: fieldSelector,
      dependentFieldsSelector: answerOptionsWrapperSelector,
      dependentInputSelector: `${answerOptionFieldSelector} input`,
      enablingCondition: ($field) => {
        return isMultipleChoiceOption($field);
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

    const dynamicFields = dynamicFieldsForAnswerOptions[fieldId];

    const onQuestionTypeChange = () => {
      if (isMultipleChoiceOption($fieldQuestionTypeSelect)) {
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
    placeholderId: "survey-question-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".survey-questions-list",
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

  autoLabelByPosition.run();
  autoButtonsByPosition.run();
})(window);
