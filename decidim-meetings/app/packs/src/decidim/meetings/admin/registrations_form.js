$(() => {
  const $form = $(".edit_meeting_registrations");

  if ($form.length > 0) {
    const $registrationsEnabled = $form.find("#meeting_registrations_enabled");
    const $availableSlots = $form.find("#meeting_available_slots");
    const $reservedSlots = $form.find("#meeting_reserved_slots");
    const $customizeRegistrationEmail = $form.find("#meeting_customize_registration_email");

    $customizeRegistrationEmail.on("click", (event) => {

      if (event.target.checked) {
        $("#customize_registration_email-div").removeClass("hidden");
      } else {
        $("#customize_registration_email-div").addClass("hidden");
      }
    })

    const toggleDisabledFields = () => {
      const enabled = $registrationsEnabled.prop("checked");
      $availableSlots.attr("disabled", !enabled);
      $reservedSlots.attr("disabled", !enabled);
      $customizeRegistrationEmail.attr("disabled", !enabled);

      $form[0].querySelectorAll(".editor-container .ProseMirror").forEach((node) => {
        node.editor.setOptions({ editable: enabled });
      });
    };

    $registrationsEnabled.on("change", toggleDisabledFields);
    toggleDisabledFields();
  }
});
