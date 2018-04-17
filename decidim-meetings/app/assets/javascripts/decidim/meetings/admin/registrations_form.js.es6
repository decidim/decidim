$(() => {
  const $form = $(".edit_meeting_registrations");

  if ($form.length > 0) {
    const $registrationsEnabled = $form.find("#meeting_registrations_enabled");
    const $availableSlots = $form.find("#meeting_available_slots");
    const $reservedSlots = $form.find("#meeting_reserved_slots");

    const toggleDisabledFields = () => {
      const enabled = $registrationsEnabled.prop("checked");
      $availableSlots.attr("disabled", !enabled);
      $reservedSlots.attr("disabled", !enabled);

      $form.find(".editor-container").each((idx, node) => {
        const quill = Quill.find(node);
        quill.enable(enabled);
      })
    };

    $registrationsEnabled.on("change", toggleDisabledFields);
    toggleDisabledFields();
  }
});
