/* eslint-disable max-lines */
/* eslint-disable require-jsdoc */

import AutoButtonsByMinItemsComponent from "src/decidim/forms/admin/auto_buttons_by_min_items.component"
import AutoSelectOptionsByTotalItemsComponent from "src/decidim/forms/admin/auto_select_options_by_total_items.component"
import AutoSelectOptionsFromUrl from "src/decidim/forms/admin/auto_select_options_from_url.component"
import createLiveTextUpdateComponent from "src/decidim/forms/admin/live_text_update.component"
import AutoButtonsByPositionComponent from "src/decidim/admin/auto_buttons_by_position.component"
import AutoLabelByPositionComponent from "src/decidim/admin/auto_label_by_position.component"
import createSortList from "src/decidim/admin/sort_list.component"
import createDynamicFields from "src/decidim/admin/dynamic_fields.component"
import createFieldDependentInputs from "src/decidim/admin/field_dependent_inputs.component"
import createQuillEditor from "src/decidim/editor"
import initLanguageChangeSelect from "src/decidim/admin/choose_language"

export default function createEditableForm() {
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

  const displayConditionFieldSelector = ".questionnaire-question-display-condition";
  const displayConditionsWrapperSelector = ".questionnaire-question-display-conditions";
  const displayConditionRemoveFieldButtonSelector = ".remove-display-condition";

  const displayConditionQuestionSelector = "select[name$=\\[decidim_condition_question_id\\]]";
  const displayConditionAnswerOptionSelector = "select[name$=\\[decidim_answer_option_id\\]]";
  const displayConditionTypeSelector = "select[name$=\\[condition_type\\]]";
  const deletedInputSelector = "input[name$=\\[deleted\\]]";

  const displayConditionValueWrapperSelector = ".questionnaire-question-display-condition-value";
  const displayconditionAnswerOptionWrapperSelector = ".questionnaire-question-display-condition-answer-option";

  const addDisplayConditionButtonSelector = ".add-display-condition";

  const removeDisplayConditionsForFirstQuestion = () => {
    $(fieldSelector).each((idx, el) => {
      const $question = $(el);
      if (idx) {
        $question.find(displayConditionsWrapperSelector).find(deletedInputSelector).val("false");
        $question.find(displayConditionsWrapperSelector).show();
      }
      else {
        $question.find(displayConditionsWrapperSelector).find(deletedInputSelector).val("true");
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
      $(el).find("input[name$=\\[position\\]]:not([name*=\\[matrix_rows\\]])").val(idx);

      autoButtonsByPosition.run();

      removeDisplayConditionsForFirstQuestion();
    }
  });

  const MULTIPLE_CHOICE_VALUES = ["single_option", "multiple_option", "sorting", "matrix_single", "matrix_multiple"];
  const MATRIX_VALUES = ["matrix_single", "matrix_multiple"];

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

  const createCollapsibleQuestion = ($target) => {
    const $collapsible = $target.find(".collapsible");
    if ($collapsible.length > 0) {
      const collapsibleId = $collapsible.attr("id").replace("-question-card", "");
      const toggleAttr = `${collapsibleId}-question-card button--collapse-question-${collapsibleId} button--expand-question-${collapsibleId}`;
      $target.find(".question--collapse").data("toggle", toggleAttr);
    }
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

  const isMultipleChoiceOption = (value) => {
    return MULTIPLE_CHOICE_VALUES.indexOf(value) >= 0;
  }

  const isMatrix = (value) => {
    return MATRIX_VALUES.indexOf(value) >= 0;
  }

  const getSelectedQuestionType = (select) => {
    const selectedOption = select.options[select.selectedIndex];
    return $(selectedOption).data("type");
  };

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

      if (!value) {
        return;
      }

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

    if (value === "match") {
      $valueWrapper.show();
    }
    else {
      $valueWrapper.hide();
    }

    if (isMultiple && (value === "not_equal" || value === "equal")) {
      $answerOptionWrapper.show();
    }
    else {
      $answerOptionWrapper.hide();
    }
  };

  const initializeDisplayConditionField = ($field) => {
    const autoSelectByUrl = createAutoSelectOptionsFromUrl($field);
    autoSelectByUrl.run();

    $field.find(displayConditionQuestionSelector).on("change", () => {
      onDisplayConditionQuestionChange($field);
    });

    $field.find(displayConditionTypeSelector).on("change", () => {
      onDisplayConditionTypeChange($field);
    });

    onDisplayConditionTypeChange($field);
    onDisplayConditionQuestionChange($field);
  }

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

  const dynamicFieldsForDisplayConditions = {};

  const setupInitialQuestionAttributes = ($target) => {
    const fieldId = $target.attr("id");
    const $fieldQuestionTypeSelect = $target.find(questionTypeSelector);

    createCollapsibleQuestion($target);
    createDynamicQuestionTitle(fieldId);

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
        return $field.val() === "multiple_option" || $field.val() === "matrix_multiple";
      }
    });

    createFieldDependentInputs({
      controllerField: $fieldQuestionTypeSelect,
      wrapperSelector: fieldSelector,
      dependentFieldsSelector: matrixRowsWrapperSelector,
      dependentInputSelector: `${matrixRowFieldSelector} input`,
      enablingCondition: ($field) => {
        return isMatrix($field.val());
      }
    });

    dynamicFieldsForAnswerOptions[fieldId] = createDynamicFieldsForAnswerOptions(fieldId);
    dynamicFieldsForMatrixRows[fieldId] = createDynamicFieldsForMatrixRows(fieldId);
    dynamicFieldsForDisplayConditions[fieldId] = createDynamicFieldsForDisplayConditions(fieldId);

    const dynamicFieldsAnswerOptions = dynamicFieldsForAnswerOptions[fieldId];
    const dynamicFieldsMatrixRows = dynamicFieldsForMatrixRows[fieldId];

    const onQuestionTypeChange = () => {
      if (isMultipleChoiceOption($fieldQuestionTypeSelect.val())) {
        const nOptions = $fieldQuestionTypeSelect.parents(fieldSelector).find(answerOptionFieldSelector).length;

        if (nOptions === 0) {
          dynamicFieldsAnswerOptions._addField();
          dynamicFieldsAnswerOptions._addField();
        }
      }

      if (isMatrix($fieldQuestionTypeSelect.val())) {
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
    addTitleAndDescriptionButtonSelector: ".add-title-and-description",
    fieldTemplateSelector: ".decidim-question-template",
    separatorTemplateSelector: ".decidim-separator-template",
    TitleAndDescriptionTemplateSelector: ".decidim-title-and-description-template",
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

      initLanguageChangeSelect();
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

      $field.find(displayConditionRemoveFieldButtonSelector).each((idx, el) => {
        dynamicFieldsForDisplayConditions[$field.attr("id")]._removeField(el);
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
}
