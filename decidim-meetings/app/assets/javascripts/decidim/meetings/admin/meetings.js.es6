$(() => {
  const $form = $('.new_meeting, .edit_meeting');

  if ($form.length > 0) {
    const $hasConciliationService = $form.find('#meeting_has_conciliation_service');
    const $conciliationServiceDescription = $form.find('#conciliation_service_description');

    const $hasSimultaneousTranslations = $form.find('#meeting_has_simultaneous_translations');
    const $simultaneousLanguages = $form.find('#simultaneous_languages');

    const toggleDependsOnSelect = ($target, $showDiv) => {
      const value = $target.prop('checked');
      $showDiv.find('input[type="text"]').attr('disabled', !value)
    };

    $hasConciliationService.on('change', (ev) => {
      const $target = $(ev.target);
      toggleDependsOnSelect($target, $conciliationServiceDescription);
    });

    $hasSimultaneousTranslations.on('change', (ev) => {
      const $target = $(ev.target);
      toggleDependsOnSelect($target, $simultaneousLanguages);
    });

    toggleDependsOnSelect($hasConciliationService, $conciliationServiceDescription);
    toggleDependsOnSelect($hasSimultaneousTranslations, $simultaneousLanguages);
  }
});
