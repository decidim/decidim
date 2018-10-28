$(() => {
  ((exports) => {
    const $conferenceScopeEnabled = $("#conference_scopes_enabled");
    const $conferenceScopeId = $("#conference_scope_id");
    const $form = $(".edit_conference, .new_conference");

    if ($form.length > 0) {
      $conferenceScopeEnabled.on("change", (event) => {
        const checked = event.target.checked;
        exports.theDataPicker.enabled($conferenceScopeId, checked);
      })
      exports.theDataPicker.enabled($conferenceScopeId, $conferenceScopeEnabled.prop("checked"));

      const $registrationsEnabled = $form.find("#conference_registrations_enabled");
      const $availableSlots = $form.find("#conference_available_slots");
      const toggleDisabledFields = () => {
        const enabled = $registrationsEnabled.prop("checked");
        $availableSlots.attr("disabled", !enabled);

        $form.find("#conference_registrations_terms .editor-container").each((idx, node) => {
          const quill = Quill.find(node);
          quill.enable(enabled);
        })
      };
      $registrationsEnabled.on("change", toggleDisabledFields);
      toggleDisabledFields();
    }

  })(window);
});
