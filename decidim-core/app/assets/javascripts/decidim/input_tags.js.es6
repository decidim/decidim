// = require tagsinput

$(() => {
  const $tagContainer = $('.js-tags-container');

  $tagContainer.tagsinput({
    tagClass: 'input__tag',
    trimValue: true
  });

});