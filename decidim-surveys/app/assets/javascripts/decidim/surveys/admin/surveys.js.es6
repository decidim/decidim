// = require jquery-tmpl

(() => {
  const $addQuestionButtons = $('.add-question');
  const templateId = 'survey-question-tmpl';
  const $wrapper = $('.survey-questions');
  const $container = $wrapper.find('.survey-questions-list');

  $.template(templateId, $(`#${templateId}`).html());

  const computeLabelOrder = () => {
    const $questions = $('.survey-question:not(.hidden)');

    $questions.each((idx, el) => {
      const $questionlabel = $(el).find('label:first');

      $questionlabel.html($questionlabel.html().replace(/#(\d+)/, `#${idx + 1}`));
    });
  };

  const addQuestion = (event) => {
    try {
      const $newQuestion = $.tmpl(templateId, {});
      const tabsId = `survey-question-${new Date().getTime()}-${Math.floor(Math.random() * 1000000)}`;
      const position = $container.find('.survey-question').length;

      $newQuestion.find('input[disabled]').attr('disabled', false);
      $newQuestion.find('input[name="survey[questions][][position]"]').val(position);
      $newQuestion.find('label:first-child').html(`${$newQuestion.find('label:first-child').html()} #${position + 1}`);
      $newQuestion.appendTo($container);
      $newQuestion.find('.label--tabs ul.tabs').attr('id', tabsId);
      $newQuestion.find('.label--tabs .tabs-title a').each(function (idx, node) {
        const href = $(node).attr('href');
        $(node).attr('href', href.replace('#', `#${tabsId}-`));
      });
      $newQuestion.find('.tabs-content').attr('data-tabs-content', tabsId);
      $newQuestion.find('.tabs-content .tabs-panel').each(function (idx, node) {
        $(node).attr('id', `${tabsId}-${$(node).attr('id')}`);
      });

      $newQuestion.foundation();
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    computeLabelOrder();

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
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    computeLabelOrder();

    event.preventDefault();
    event.stopPropagation();
  };

  $addQuestionButtons.on('click', addQuestion);
  $wrapper.on('click', '.remove-question', removeQuestion);

  if (DecidimAdmin) {
    DecidimAdmin.sortList('.survey-questions-list:not(.published)', {
      handle: 'label',
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: ($children) => {
        $children.each((idx, el) => {
          $(el).find('input[name="survey[questions][][position]"]').val(idx);
        });
        computeLabelOrder();
      }
    });
  }
})();
