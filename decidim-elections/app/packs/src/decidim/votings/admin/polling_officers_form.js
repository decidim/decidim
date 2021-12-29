import createFieldDependentInputs from "src/decidim/admin/field_dependent_inputs.component"

$(() => {
  const $participantType = $("#polling_officer_existing_user");

  createFieldDependentInputs({
    controllerField: $participantType,
    wrapperSelector: ".user-fields",
    dependentFieldsSelector: ".user-fields--email",
    dependentInputSelector: "input",
    enablingCondition: ($field) => {
      return $field.val() === "false"
    }
  });

  createFieldDependentInputs({
    controllerField: $participantType,
    wrapperSelector: ".user-fields",
    dependentFieldsSelector: ".user-fields--name",
    dependentInputSelector: "input",
    enablingCondition: ($field) => {
      return $field.val() === "false"
    }
  });

  createFieldDependentInputs({
    controllerField: $participantType,
    wrapperSelector: ".user-fields",
    dependentFieldsSelector: ".user-fields--user-picker",
    dependentInputSelector: "input",
    enablingCondition: ($field) => {
      return $field.val() === "true"
    }
  });
})
