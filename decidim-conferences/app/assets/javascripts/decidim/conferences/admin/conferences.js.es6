$(() => {
  ((exports) => {
    const $conferenceScopeEnabled = $("#conference_scopes_enabled");
    const $conferenceScopeId = $("#conference_scope_id");

    if ($(".edit_conference, .new_conference").length > 0) {
      $conferenceScopeEnabled.on("change", (event) => {
        const checked = event.target.checked;
        exports.theDataPicker.enabled($conferenceScopeId, checked);
      })
      exports.theDataPicker.enabled($conferenceScopeId, $conferenceScopeEnabled.prop("checked"));
    }

  })(window);
});
