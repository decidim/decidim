((exports) => {
  const { createFieldDependentInputs } = exports.DecidimAdmin;

  const $assemblyMemberPosition = $("#assembly_member_position");

  createFieldDependentInputs({
    controllerField: $assemblyMemberPosition,
    wrapperSelector: ".position-fields",
    dependentFieldsSelector: ".position-fields--position-other",
    dependentInputSelector: "input",
    enablingCondition: ($field) => {
      return $field.val() === "other"
    }
  });
})(window);
