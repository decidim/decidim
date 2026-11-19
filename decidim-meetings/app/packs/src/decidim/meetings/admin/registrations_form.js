document.addEventListener("turbo:load", () => {
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

    const toggleEditors = (enabled, editor = null) => {
      const editors = new Set(
        Array.from($form[0].querySelectorAll(".editor-container .ProseMirror")).
          map((node) => node.editor)
      );

      if (editor) {
        editors.add(editor);
      }

      editors.forEach((instance) => instance?.setOptions({ editable: enabled }));
    };

    const toggleDisabledFields = () => {
      const enabled = $registrationsEnabled.prop("checked");
      $availableSlots.attr("disabled", !enabled);
      $reservedSlots.attr("disabled", !enabled);
      $customizeRegistrationEmail.attr("disabled", !enabled);

      toggleEditors(enabled);
    };

    $form[0].addEventListener("editor:initialized", (event) => {
      toggleEditors($registrationsEnabled.prop("checked"), event.detail?.editor);
    });

    $registrationsEnabled.on("change", toggleDisabledFields);
    toggleDisabledFields();
  }
});
