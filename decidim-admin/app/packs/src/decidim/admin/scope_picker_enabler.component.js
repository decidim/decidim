$(() => {
  const $ComponentScopeEnabled = $("#component_settings_scopes_enabled");
  const $ComponentScopeId = $("#component_settings_scope_id");

  if ($(".edit_component, .new_component").length > 0) {
    $ComponentScopeEnabled.on("change", (event) => {
      const checked = event.target.checked;
      window.theDataPicker.enabled($ComponentScopeId, checked);
    })
    window.theDataPicker.enabled($ComponentScopeId, $ComponentScopeEnabled.prop("checked"));
  }
});
