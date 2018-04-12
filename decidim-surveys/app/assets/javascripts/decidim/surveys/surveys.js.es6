// = require ./option_attached_inputs.component
// = require ./autosortable_checkboxes.component

((exports) => {
  const { createOptionAttachedInputs, createAutosortableCheckboxes } = exports.Decidim;

  $(".radio-button-collection, .check-box-collection").each((idx, el) => {
    createOptionAttachedInputs({
      wrapperField: $(el),
      controllerFieldSelector: "input[type=radio], input[type=checkbox]",
      dependentInputSelector: "input[type=text], input[type=hidden]"
    });
  });

  $(".sortable-check-box-collection").each((idx, el) => {
    createAutosortableCheckboxes({
      wrapperField: $(el)
    })
  });
})(window);
