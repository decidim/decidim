$(() => {
  const $participatoryProcessScopeEnabled = $("#participatory_process_scopes_enabled");
  const $participatoryProcessScopeId = $("#participatory_process_scope_id");
  const $participatoryProcessScopeTypeId = $("#participatory_process_scope_type_max_depth_id");

  if ($(".edit_participatory_process, .new_participatory_process").length > 0) {
    $participatoryProcessScopeEnabled.on("change", (event) => {
      const checked = event.target.checked;
      $participatoryProcessScopeId.attr("disabled", !checked);
      if (checked === true) {
        $participatoryProcessScopeTypeId.removeAttr("disabled");
      } else {
        $participatoryProcessScopeTypeId.attr("disabled", true)
      }
      $participatoryProcessScopeId.attr("disabled", !$participatoryProcessScopeEnabled.prop("checked"));
    })
  }
});
