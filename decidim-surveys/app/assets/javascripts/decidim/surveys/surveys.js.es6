// = require ./option_attached_inputs.component

((exports) => {
  const { createOptionAttachedInputs } = exports.Decidim;

  $(".radio-button-collection, .check-box-collection").each((idx, el) => {
    createOptionAttachedInputs({
      wrapperField: $(el),
      controllerFieldSelector: "input[type=radio], input[type=checkbox]",
      dependentInputSelector: "input[type=text]"
    });
  });
})(window);
