// = require jquery-tmpl
// = require ./auto_label_by_position.component
// = require ./dynamic_fields.component

((exports) => {
  const { AutoLabelByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: '.survey-question:not(.hidden)',
    labelSelector: '.card-title span',
    onPositionComputed: (el, idx) => {
      $(el).find('input[name="survey[questions][][position]"]').val(idx);
    }
  });

  const createSortableList = () => {
    createSortList('.survey-questions-list:not(.published)', {
      handle: '.card-divider',
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => { autoLabelByPosition.run() }
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
    onAddField: () => {
      createSortableList();
      autoLabelByPosition.run();
    },
    onRemoveField: () => {
      autoLabelByPosition.run();
    }
  });

  createSortableList();
})(window);
