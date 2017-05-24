// = require jquery-tmpl

(() => {
  const $addQuestionButtons = $('.add-question');
  const templateId = 'survey-question-tmpl';
  const $wrapper = $('.survey-questions');
  const $container = $wrapper.find('.survey-questions-list');

  $.template(templateId, $(`#${templateId}`).html());

  const computeQuestionPositions = () => {
    const $questions = $('.survey-question:not(.hidden)');

    $questions.each((idx, el) => {
      const $questionlabel = $(el).find('label:first');
      const questionLabelContent = $questionlabel.html();

      $(el).find('input[name="survey[questions][][position]"]').val(idx);

      if (questionLabelContent.match(/#(\d+)/)) {
        $questionlabel.html(questionLabelContent.replace(/#(\d+)/, `#${idx + 1}`));
      } else {
        $questionlabel.html(`${questionLabelContent} #${idx + 1}`);
      }
    });
  };

  const createSortableList = () => {
    if (DecidimAdmin) {
      DecidimAdmin.sortList('.survey-questions-list:not(.published)', {
        handle: 'label',
        placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
        forcePlaceholderSize: true,
        onSortUpdate: computeQuestionPositions
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
      computeQuestionPositions();
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    event.preventDefault();
    event.stopPropagation();
  };

  const removeQuestion = (event) => {
    try {
      const $target = $(event.target);
      const $question = $target.parent('.survey-question');
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

      computeQuestionPositions();
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    event.preventDefault();
    event.stopPropagation();
  };

  $addQuestionButtons.on('click', addQuestion);
  $wrapper.on('click', '.remove-question', removeQuestion);

  createSortableList();
  computeQuestionPositions();
})();
