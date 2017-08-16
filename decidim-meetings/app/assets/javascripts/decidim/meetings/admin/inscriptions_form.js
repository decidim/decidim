$(() => {
  const $form = $('.edit_meeting_inscriptions');

  if ($form.length > 0) {
    const $inscriptionsEnabled = $form.find('#meeting_inscriptions_enabled');
    const $availableSlots = $form.find('#meeting_available_slots');

    const toggleDisabledFields = () => {
      const enabled = $inscriptionsEnabled.prop('checked');
      $availableSlots.attr('disabled', !enabled);

      $form.find('.editor-container').each((idx, node) => {
        const quill = Quill.find(node);
        quill.enable(enabled);
      })
    };

    $inscriptionsEnabled.on('change', toggleDisabledFields);
    toggleDisabledFields();
  }
});
