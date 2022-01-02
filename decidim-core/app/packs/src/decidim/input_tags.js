import "bootstrap-tagsinput-2021"

$(() => {
  const $tagContainer = $(".js-tags-container");

  // Initialize
  $tagContainer.tagsinput({
    tagClass: "input__tag",
    trimValue: true
  });

});
