$(() => {
  ((exports) => {
    const $assemblyScopeEnabled = $('#assembly_scopes_enabled');
    const $assemblyScopeId = $("#assembly_scope_id");
    const $assemblyPrivate = $('#assembly_private_assembly');
    const $assemblyUserIds = $("#assembly_user_ids");

    if ($('.edit_assembly, .new_assembly').length > 0) {
      $assemblyScopeEnabled.on('change', (event) => {
        const checked = event.target.checked;
        exports.theDataPicker.enabled($assemblyScopeId, checked);
      })
      exports.theDataPicker.enabled($assemblyScopeId, $assemblyScopeEnabled.prop('checked'));

      $assemblyPrivate.on('change', (event) => {
        const checked = event.target.checked;
        $assemblyUserIds.prop('disabled', !checked);
      })
      $assemblyUserIds.prop('disabled', !$assemblyPrivate.prop('checked'));

    }
  })(window);
});
