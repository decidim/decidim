((exports) => {
  const { createFieldDependentInputs } = exports.DecidimAdmin;

  const $conferenceSpeakerType = $("#conference_speaker_existing_user");

  createFieldDependentInputs({
    controllerField: $conferenceSpeakerType,
    wrapperSelector: ".user-fields",
    dependentFieldsSelector: ".user-fields--full-name",
    dependentInputSelector: "input",
    enablingCondition: ($field) => {
      return $field.val() === "false"
    }
  });

  createFieldDependentInputs({
    controllerField: $conferenceSpeakerType,
    wrapperSelector: ".user-fields",
    dependentFieldsSelector: ".user-fields--user-picker",
    dependentInputSelector: "input",
    enablingCondition: ($field) => {
      return $field.val() === "true"
    }
  });

})(window);
