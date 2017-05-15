// = require jquery-tmpl

((exports) => {
  const $addQuestionButtons = $('.add-question');
  const templateId = 'survey-question-tmpl';
  const $container = $('.survey-questions');

  $.template(templateId, $(`#${templateId}`).html());

  const addQuestion = (event) => {
    try {
      const $newQuestion = $.tmpl(templateId, {});
      const tabsId = `survey-question-${+new Date()}-${~~(Math.random() * 1000000)}`;

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

      // TODO: editor?
      // window.Decidim.createQuillEditor($newQuestion[0]);
    } catch(e) {
      console.error(e);
    }

    event.preventDefault();
    event.stopPropagation();
  };

  $addQuestionButtons.on('click', addQuestion);
})(document);
