import createFieldDependentInputs from "src/decidim/admin/field_dependent_inputs.component"

document.addEventListener("turbo:load", () => {
  const $memberType = $('[name="member[existing_user]"]')

  if ($memberType.length === 0) {
    return
  }

  createFieldDependentInputs({
    controllerField: $memberType,
    wrapperSelector: ".member-fields",
    dependentFieldsSelector: ".member-fields--new-participant",
    dependentInputSelector: "input",
    enablingCondition: () => {
      return $("#member_existing_user_false").is(":checked")
    }
  })

  createFieldDependentInputs({
    controllerField: $memberType,
    wrapperSelector: ".member-fields",
    dependentFieldsSelector: ".member-fields--existing-participant",
    dependentInputSelector: "input",
    enablingCondition: () => {
      return $("#member_existing_user_true").is(":checked")
    }
  })
})
