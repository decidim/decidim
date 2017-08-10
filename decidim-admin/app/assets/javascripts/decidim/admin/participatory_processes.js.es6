$(() => {
  const $participatoryProcessScopeEnabled = $('#participatory_process_scopes_enabled');
  const $participatoryProcessScopeId = $("#participatory_process_scope_id");

  if ($('.edit_participatory_process').length > 0) {
    $participatoryProcessScopeEnabled.on('change', (event) => {
      const checked = event.target.checked;
      $participatoryProcessScopeId.attr("disabled", !checked);
    })
    $participatoryProcessScopeId.attr("disabled", !$participatoryProcessScopeEnabled.prop('checked'));
  }
});
