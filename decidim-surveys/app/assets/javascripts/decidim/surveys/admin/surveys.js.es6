// = require jquery-tmpl

(() => {
  const $addQuestionButtons = $('.add-question');
  const templateId = 'survey-question-tmpl';
  const $container = $('.survey-questions');

  $.template(templateId, $(`#${templateId}`).html());

  const addQuestion = (event) => {
    try {
      const $newQuestion = $.tmpl(templateId, {});
      const tabsId = `survey-question-${new Date().setUTCMilliseconds()}-${Math.floor(Math.random() * 1000000)}`;

      $newQuestion.find('input[disabled]').attr('disabled', false);
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
        $question.append(deleteInput);
        $question.hide();
      } else {
        $question.remove();
      }
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    event.preventDefault();
    event.stopPropagation();
  };

  $addQuestionButtons.on('click', addQuestion);
  $container.on('click', '.remove-question', removeQuestion);
})();
