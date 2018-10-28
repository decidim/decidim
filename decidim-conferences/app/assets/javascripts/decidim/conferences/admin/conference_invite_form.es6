((exports) => {
  const { createFieldDependentInputs } = exports.DecidimAdmin;

  const $attendeeType = $('[name="conference_registration_invite[existing_user]"');

  createFieldDependentInputs({
    controllerField: $attendeeType,
    wrapperSelector: ".attendee-fields",
    dependentFieldsSelector: ".attendee-fields--new-user",
    dependentInputSelector: "input",
    enablingCondition: () => {
      return $("#conference_registration_invite_existing_user_false").is(":checked")
    }
  });

  createFieldDependentInputs({
    controllerField: $attendeeType,
    wrapperSelector: ".attendee-fields",
    dependentFieldsSelector: ".attendee-fields--user-picker",
    dependentInputSelector: "input",
    enablingCondition: () => {
      return $("#conference_registration_invite_existing_user_true").is(":checked")
    }
  });
})(window);
