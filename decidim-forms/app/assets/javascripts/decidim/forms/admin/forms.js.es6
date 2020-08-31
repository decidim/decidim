// = require ./auto_buttons_by_min_items.component
// = require ./auto_select_options_by_total_items.component
// = require ./live_text_update.component

((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, AutoButtonsByMinItemsComponent, AutoSelectOptionsByTotalItemsComponent, createLiveTextUpdateComponent, createFieldDependentInputs, createDynamicFields, createSortList } = exports.DecidimAdmin;
  const { createQuillEditor } = exports.Decidim;

  const wrapperSelector = ".questionnaire-questions";
  const fieldSelector = ".questionnaire-question";
  const questionTypeSelector = "select[name$=\\[question_type\\]]";
  const answerOptionFieldSelector = ".questionnaire-question-answer-option";
  const answerOptionsWrapperSelector = ".questionnaire-question-answer-options";
  const answerOptionRemoveFieldButtonSelector = ".remove-answer-option";
  const matrixRowFieldSelector = ".questionnaire-question-matrix-row";
  const matrixRowsWrapperSelector = ".questionnaire-question-matrix-rows";
  const matrixRowRemoveFieldButtonSelector = ".remove-matrix-row";
  const addMatrixRowButtonSelector = ".add-matrix-row";
  const maxChoicesWrapperSelector = ".questionnaire-question-max-choices";

  const MULTIPLE_CHOICE_VALUES = ["single_option", "multiple_option", "sorting", "matrix_single", "matrix_multiple"];
  const MATRIX_VALUES = ["matrix_single", "matrix_multiple"];

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".questionnaire-question:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".questionnaire-question:not(.hidden)",
    hideOnFirstSelector: ".move-up-question",
    hideOnLastSelector: ".move-down-question"
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

  const createSortableList = () => {
    createSortList(".questionnaire-questions-list:not(.published)", {
      handle: ".question-divider",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => {
        autoLabelByPosition.run();
        autoButtonsByPosition.run();
      }
    });
  };

  const createDynamicQuestionTitle = (fieldId) => {
    const targetSelector = `#${fieldId} .question-title-statement`;
    const locale = $(targetSelector).data("locale");
    const maxLength = $(targetSelector).data("max-length");
    const omission = $(targetSelector).data("omission");
    const placeholder = $(targetSelector).data("placeholder");

    return createLiveTextUpdateComponent({
      inputSelector: `#${fieldId} input[name$=\\[body_${locale}\\]]`,
      targetSelector: targetSelector,
      maxLength: maxLength,
      omission: omission,
      placeholder: placeholder
    });
  }

  const createDynamicFieldsForAnswerOptions = (fieldId) => {
    const autoButtons = createAutoButtonsByMinItemsForAnswerOptions(fieldId);
    const autoSelectOptions = createAutoMaxChoicesByNumberOfAnswerOptions(fieldId);

    return createDynamicFields({
      placeholderId: "questionnaire-question-answer-option-id",
      wrapperSelector: `#${fieldId} ${answerOptionsWrapperSelector}`,
      containerSelector: ".questionnaire-question-answer-options-list",
      fieldSelector: answerOptionFieldSelector,
      addFieldButtonSelector: ".add-answer-option",
      fieldTemplateSelector: ".decidim-answer-option-template",
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

  const createDynamicFieldsForMatrixRows = (fieldId) => {
    return createDynamicFields({
      placeholderId: "questionnaire-question-matrix-row-id",
      wrapperSelector: `#${fieldId} ${matrixRowsWrapperSelector}`,
      containerSelector: ".questionnaire-question-matrix-rows-list",
      fieldSelector: matrixRowFieldSelector,
      addFieldButtonSelector: addMatrixRowButtonSelector,
      fieldTemplateSelector: ".decidim-matrix-row-template",
      removeFieldButtonSelector: matrixRowRemoveFieldButtonSelector,
      onAddField: () => {
      },
      onRemoveField: () => {
      }
    });
  };

  const dynamicFieldsForMatrixRows = {};

  const isMultipleChoiceOption = ($selectField) => {
    const value = $selectField.val();

    return MULTIPLE_CHOICE_VALUES.indexOf(value) >= 0;
  }

  const isMatrix = ($selectField) => {
    const value = $selectField.val();

    return MATRIX_VALUES.indexOf(value) >= 0;
  }

  const setupInitialQuestionAttributes = ($target) => {
    const fieldId = $target.attr("id");
    const $fieldQuestionTypeSelect = $target.find(questionTypeSelector);

    createDynamicQuestionTitle(fieldId);

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
        return $field.val() === "multiple_option" || $field.val() === "matrix_multiple";
      }
    });

    createFieldDependentInputs({
      controllerField: $fieldQuestionTypeSelect,
      wrapperSelector: fieldSelector,
      dependentFieldsSelector: matrixRowsWrapperSelector,
      dependentInputSelector: `${matrixRowFieldSelector} input`,
      enablingCondition: ($field) => {
        return isMatrix($field);
      }
    });

    dynamicFieldsForAnswerOptions[fieldId] = createDynamicFieldsForAnswerOptions(fieldId);
    dynamicFieldsForMatrixRows[fieldId] = createDynamicFieldsForMatrixRows(fieldId);

    const dynamicFieldsAnswerOptions = dynamicFieldsForAnswerOptions[fieldId];
    const dynamicFieldsMatrixRows = dynamicFieldsForMatrixRows[fieldId];

    const onQuestionTypeChange = () => {
      if (isMultipleChoiceOption($fieldQuestionTypeSelect)) {
        const nOptions = $fieldQuestionTypeSelect.parents(fieldSelector).find(answerOptionFieldSelector).length;

        if (nOptions === 0) {
          dynamicFieldsAnswerOptions._addField();
          dynamicFieldsAnswerOptions._addField();
        }
      }

      if (isMatrix($fieldQuestionTypeSelect)) {
        const nRows = $fieldQuestionTypeSelect.parents(fieldSelector).find(matrixRowFieldSelector).length;

        if (nRows === 0) {
          dynamicFieldsMatrixRows._addField();
          dynamicFieldsMatrixRows._addField();
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
    addSeparatorButtonSelector: ".add-separator",
    fieldTemplateSelector: ".decidim-question-template",
    separatorTemplateSelector: ".decidim-separator-template",
    removeFieldButtonSelector: ".remove-question",
    moveUpFieldButtonSelector: ".move-up-question",
    moveDownFieldButtonSelector: ".move-down-question",
    onAddField: ($field) => {
      const $collapsible = $field.find(".collapsible");
      if ($collapsible.length > 0) {
        const collapsibleId = $collapsible.attr("id").replace("-question-card", "");
        const toggleAttr = `${collapsibleId}-question-card button--collapse-question-${collapsibleId} button--expand-question-${collapsibleId}`;
        $field.find(".question--collapse").data("toggle", toggleAttr);
      }

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
      $field.find(matrixRowRemoveFieldButtonSelector).each((idx, el) => {
        dynamicFieldsForMatrixRows[$field.attr("id")]._removeField(el);
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
