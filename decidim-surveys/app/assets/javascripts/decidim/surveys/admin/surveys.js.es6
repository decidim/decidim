// = require jquery-tmpl
// = require ./auto_label_by_position.component

((exports) => {
  const { AutoLabelByPositionComponent } = exports.DecidimAdmin;

  const $addQuestionButtons = $('.add-question');
  const templateId = 'survey-question-tmpl';
  const $wrapper = $('.survey-questions');
  const $container = $wrapper.find('.survey-questions-list');

  const autoLabelByPosition = new AutoLabelByPositionComponent('.survey-question:not(.hidden)', '.card-title span');

  $.template(templateId, $(`#${templateId}`).html());

  const createSortableList = () => {
    if (DecidimAdmin) {
      DecidimAdmin.sortList('.survey-questions-list:not(.published)', {
        handle: '.card-divider',
        placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
        forcePlaceholderSize: true,
        onSortUpdate: () => { autoLabelByPosition.run() }
      });
    }
  };

  const addQuestion = (event) => {
    try {
      const tabsId = `survey-question-${new Date().getTime()}-${Math.floor(Math.random() * 1000000)}`;
      const position = $container.find('.survey-question').length;
      const $newQuestion = $.tmpl(templateId, {
        position,
        questionLabelPosition: position + 1,
        tabsId
      });

      $newQuestion.find('[disabled]').attr('disabled', false);
      $newQuestion.find('ul.tabs').attr('data-tabs', true);
      $newQuestion.appendTo($container);

      $newQuestion.foundation();

      createSortableList();
      autoLabelByPosition.run();
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    event.preventDefault();
    event.stopPropagation();
  };

  const removeQuestion = (event) => {
    try {
      const $target = $(event.target);
      const $question = $target.parents('.survey-question');
      const $idInput = $question.find('input[name="survey[questions][][id]"]');

      if ($idInput.length > 0) {
        const deleteInput = document.createElement('input');
        deleteInput.name = "survey[questions][][deleted]";
        deleteInput.type = "hidden";
        deleteInput.value = "true";
        $question.addClass('hidden');
        $question.append(deleteInput);
        $question.hide();
      } else {
        $question.remove();
      }

      autoLabelByPosition.run();
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    event.preventDefault();
    event.stopPropagation();
  };

  $addQuestionButtons.on('click', addQuestion);
  $wrapper.on('click', '.remove-question', removeQuestion);

  createSortableList();
  autoLabelByPosition.run();
})(window);
