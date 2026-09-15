import createFieldDependentInputs from "src/decidim/admin/field_dependent_inputs.component"

document.addEventListener("turbo:load", () => {
  const $attendeeType = $('[name="meeting_registration_invite[attendee_type]"]');

  createFieldDependentInputs({
    controllerField: $attendeeType,
    wrapperSelector: ".user-picker-fields",
    dependentFieldsSelector: ".user-picker-fields--name",
    dependentInputSelector: "input, select",
    enablingCondition: () => {
      return $("#meeting_registration_invite_attendee_type_name").is(":checked")
    }
  });

  createFieldDependentInputs({
    controllerField: $attendeeType,
    wrapperSelector: ".user-picker-fields",
    dependentFieldsSelector: ".user-picker-fields--email",
    dependentInputSelector: "input",
    enablingCondition: () => {
      return $("#meeting_registration_invite_attendee_type_email").is(":checked")
    }
  });
})
