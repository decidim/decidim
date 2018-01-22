$(() => {
  ((exports) => {
    const $participatoryProcessScopeEnabled = $('#participatory_process_scopes_enabled');
    const $participatoryProcessScopeId = $("#participatory_process_scope_id");
    const $participatoryProcessPrivate = $('#participatory_process_private_process');
    const $participatoryProcessUserIds = $("#participatory_process_user_ids");

    if ($('.edit_participatory_process, .new_participatory_process').length > 0) {
      $participatoryProcessScopeEnabled.on('change', (event) => {
        const checked = event.target.checked;
        exports.theDataPicker.enabled($participatoryProcessScopeId, checked);
      })
      exports.theDataPicker.enabled($participatoryProcessScopeId, $participatoryProcessScopeEnabled.prop('checked'));

      $participatoryProcessPrivate.on('change', (event) => {
        const checked = event.target.checked;
        $participatoryProcessUserIds.prop('disabled', !checked);
      })
      $participatoryProcessUserIds.prop('disabled', !$participatoryProcessPrivate.prop('checked'));
    }
  })(window);
});
