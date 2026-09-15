import createFieldDependentInputs from "src/decidim/admin/field_dependent_inputs.component"

document.addEventListener("turbo:load", () => {
  const $memberType = $('[name="member[member_type]"]');

  createFieldDependentInputs({
    controllerField: $memberType,
    wrapperSelector: ".user-picker-fields",
    dependentFieldsSelector: ".user-picker-fields--name",
    dependentInputSelector: "input, select",
    enablingCondition: () => {
      return $("#member_member_type_name").is(":checked")
    }
  });

  createFieldDependentInputs({
    controllerField: $memberType,
    wrapperSelector: ".user-picker-fields",
    dependentFieldsSelector: ".user-picker-fields--email",
    dependentInputSelector: "input",
    enablingCondition: () => {
      return $("#member_member_type_email").is(":checked")
    }
  });
})
