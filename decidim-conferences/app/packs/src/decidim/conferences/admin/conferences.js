document.addEventListener("turbo:load", () => {
  const $conferenceScopeEnabled = $("#conference_scopes_enabled");
  const $conferenceScopeId = $("#conference_scope_id");
  const $form = $(".edit_conference, .new_conference");

  if ($form.length > 0) {
    $conferenceScopeEnabled.on("change", (event) => {
      const checked = event.target.checked;
      $conferenceScopeId.attr("disabled", !checked);
    })
    $conferenceScopeId.attr("disabled", !$conferenceScopeEnabled.prop("checked"));

    const $registrationsEnabled = $form.find("#conference_registrations_enabled");
    const $availableSlots = $form.find("#conference_available_slots");
    const $registrationTerms = $form.find("#conference_registrations_terms");
    const toggleEditors = (enabled, editor = null) => {
      const editors = new Set(
        Array.from($registrationTerms[0].querySelectorAll(".editor-container .ProseMirror")).
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

      toggleEditors(enabled);
    };

    $registrationTerms[0].addEventListener("editor:initialized", (event) => {
      toggleEditors($registrationsEnabled.prop("checked"), event.detail?.editor);
    });

    $registrationsEnabled.on("change", toggleDisabledFields);
    toggleDisabledFields();
  }
});
