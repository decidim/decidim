$(() => {
  ((exports) => {
    const $assemblyScopeEnabled = $('#assembly_scopes_enabled');
    const $assemblyScopeId = $("#assembly_scope_id");

    if ($('.edit_assembly, .new_assembly').length > 0) {
      $assemblyScopeEnabled.on('change', (event) => {
        const checked = event.target.checked;
        exports.Decidim.DataPicker.enabled($assemblyScopeId, checked);
      })
      exports.Decidim.DataPicker.enabled($assemblyScopeId, $assemblyScopeEnabled.prop('checked'));
    }
  })(window);
});
