// TODO-blat: this is an external jquery plugin I haven't found a reference in npmjs
import './tagsinput'

$(() => {
  const $tagContainer = $(".js-tags-container");

  // Initialize
  $tagContainer.tagsinput({
    tagClass: "input__tag",
    trimValue: true
  });

});
