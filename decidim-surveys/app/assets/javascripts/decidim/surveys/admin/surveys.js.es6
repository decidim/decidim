// = require jquery-tmpl
// = require ./auto_label_by_position.component
// = require ./dynamic_fields.component

((exports) => {
  const { AutoLabelByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: '.survey-question:not(.hidden)',
    labelSelector: '.card-title span:first',
    onPositionComputed: (el, idx) => {
      $(el).find('input[name="survey[questions][][position]"]').val(idx);
    }
  });

  const createSortableList = () => {
    createSortList('.survey-questions-list:not(.published)', {
      handle: '.question-divider',
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => { autoLabelByPosition.run() }
    });
  };

  const createDynamicFieldsForAnswerOptions = (fieldId) => {
    createDynamicFields({
      templateId: `survey-question-answer-option-tmpl`,
      tabsPrefix: `survey-question-answer-option`,
      wrapperSelector: `#${fieldId} .survey-question-answer-options`,
      containerSelector: `.survey-question-answer-options-list`,
      fieldSelector: `.survey-question-answer-option`,
      addFieldButtonSelector: `.add-answer-option`,
      removeFieldButtonSelector: `.remove-answer-option`
    });
  };

  createDynamicFields({
    templateId: 'survey-question-tmpl',
    tabsPrefix: 'survey-question',
    wrapperSelector: '.survey-questions',
    containerSelector: '.survey-questions-list',
    fieldSelector: '.survey-question',
    addFieldButtonSelector: '.add-question',
    removeFieldButtonSelector: '.remove-question',
    onAddField: ($field) => {
      const fieldId = $field.attr('id');

      createSortableList();
      autoLabelByPosition.run();
      createDynamicFieldsForAnswerOptions(fieldId);
    },
    onRemoveField: () => {
      autoLabelByPosition.run();
    }
  });

  createSortableList();

  $('.survey-question').each((idx, el) => {
    createDynamicFieldsForAnswerOptions($(el).attr('id'));
  });
})(window);
