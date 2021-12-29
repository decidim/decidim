import createFieldDependentInputs from "src/decidim/admin/field_dependent_inputs.component"

$(() => {
  const $debateType = $('[name="debate[finite]"');

  createFieldDependentInputs({
    controllerField: $debateType,
    wrapperSelector: ".debate-fields",
    dependentFieldsSelector: ".debate-fields--open",
    dependentInputSelector: "input",
    enablingCondition: () => {
      return $("#debate_finite_false").is(":checked")
    }
  });

  createFieldDependentInputs({
    controllerField: $debateType,
    wrapperSelector: ".debate-fields",
    dependentFieldsSelector: ".debate-fields--finite",
    dependentInputSelector: "input",
    enablingCondition: () => {
      return $("#debate_finite_true").is(":checked")
    }
  });
})
