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

      const $customLinkEnabled = $form.find("#conference_custom_link_enabled");
      const toggleCustomLinksFields = () => {
        const enabled = $customLinkEnabled.prop("checked");
        $form.find("[data-tabs-content='conference-custom_link_name-tabs'] input").each((idx, node) => {
          $form.find(node).attr("disabled", !enabled);
        });
        $form.find("#conference_custom_link_url").attr("disabled", !enabled);
      };
      $customLinkEnabled.on("change", toggleCustomLinksFields);
      toggleCustomLinksFields();
    }

  })(window);
});
