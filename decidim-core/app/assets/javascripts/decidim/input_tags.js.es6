// = require tagsinput

$(() => {
  const $tagContainer = $(".js-tags-container");

  // Initialize
  $tagContainer.tagsinput({
    tagClass: "input__tag",
    trimValue: true
  });

});
