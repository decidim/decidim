// = require ./auto_label_by_position.component
// = require ./auto_buttons_by_position.component
// = require ./auto_buttons_by_min_items.component
// = require ./dynamic_fields.component

((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, AutoButtonsByMinItemsComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;
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

  const createAutoButtonsByMinItemsForAnswerOptions = (fieldId) => {
    return new AutoButtonsByMinItemsComponent({
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

    return createDynamicFields({
      placeholderId: "survey-question-answer-option-id",
      wrapperSelector: `#${fieldId} ${answerOptionsWrapperSelector}`,
      containerSelector: ".survey-question-answer-options-list",
      fieldSelector: answerOptionFieldSelector,
      addFieldButtonSelector: ".add-answer-option",
      removeFieldButtonSelector: answerOptionRemoveFieldButtonSelector,
      onAddField: () => {
        autoButtons.run();
      },
      onRemoveField: () => {
        autoButtons.run();
      }
    });
  };

  const dynamicFieldsForAnswerOptions = {};

  const setAnswerOptionsWrapperVisibility = ($target) => {
    const $answerOptionsWrapper = $target.parents(fieldSelector).find(answerOptionsWrapperSelector);
    const value = $target.val();
    const $answerOptionsInputs = $answerOptionsWrapper.find(`${answerOptionFieldSelector} input`);

    if (value === "single_option" || value === "multiple_option") {
      $answerOptionsInputs.prop("disabled", false);
      $answerOptionsWrapper.show();
    } else {
      $answerOptionsInputs.prop("disabled", true);
      $answerOptionsWrapper.hide();
    }
  };

  const setMaxChoicesWrapperVisibility = ($target) => {
    const $maxChoicesWrapper = $target.parents(fieldSelector).find(maxChoicesWrapperSelector);
    const $maxChoicesSelect = $maxChoicesWrapper.find("select");
    const value = $target.val();

    if (value === "multiple_option") {
      $maxChoicesSelect.prop("disabled", false);
      $maxChoicesWrapper.show();
    } else {
      $maxChoicesSelect.prop("disabled", true);
      $maxChoicesWrapper.hide();
    }
  };

  const setupInitialQuestionAttributes = ($target) => {
    const fieldId = $target.attr("id");
    const $fieldQuestionTypeSelect = $target.find(questionTypeSelector);

    dynamicFieldsForAnswerOptions[fieldId] = createDynamicFieldsForAnswerOptions(fieldId);

    const dynamicFields = dynamicFieldsForAnswerOptions[fieldId];

    const onQuestionTypeChange = () => {
      const value = $fieldQuestionTypeSelect.val();

      if (value === "single_option" || value === "multiple_option") {
        const nOptions = $fieldQuestionTypeSelect.parents(fieldSelector).find(answerOptionFieldSelector).length;

        if (nOptions === 0) {
          dynamicFields._addField();
          dynamicFields._addField();
        }
      }

      setAnswerOptionsWrapperVisibility($fieldQuestionTypeSelect);
      setMaxChoicesWrapperVisibility($fieldQuestionTypeSelect);
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
