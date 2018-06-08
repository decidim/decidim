((exports) => {
  const { createFieldDependentInputs } = exports.DecidimAdmin;

  const $assemblyMemberType = $("#assembly_member_existing_user");

  createFieldDependentInputs({
    controllerField: $assemblyMemberType,
    wrapperSelector: ".user-fields",
    dependentFieldsSelector: ".user-fields--full-name",
    dependentInputSelector: "input",
    enablingCondition: ($field) => {
      return $field.val() === "false"
    }
  });

  createFieldDependentInputs({
    controllerField: $assemblyMemberType,
    wrapperSelector: ".user-fields",
    dependentFieldsSelector: ".user-fields--user-picker",
    dependentInputSelector: "input",
    enablingCondition: ($field) => {
      return $field.val() === "true"
    }
  });

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
