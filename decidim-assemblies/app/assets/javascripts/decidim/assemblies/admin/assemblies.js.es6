$(() => {
  ((exports) => {
    const $assemblyScopeEnabled = $("#assembly_scopes_enabled");
    const $assemblyScopeId = $("#assembly_scope_id");

    if ($(".edit_assembly, .new_assembly").length > 0) {
      $assemblyScopeEnabled.on("change", (event) => {
        const checked = event.target.checked;
        exports.theDataPicker.enabled($assemblyScopeId, checked);
      })
      exports.theDataPicker.enabled($assemblyScopeId, $assemblyScopeEnabled.prop("checked"));
    }


    const $form = $(".assembly_form_admin");

    if ($form.length > 0) {

      const $privateSpace = $form.find("#private_space");
      const $isTransparent = $form.find("#is_transparent");
      const $specialFeatures = $form.find("#special_features");


      const toggleDisabledHiddenFields = () => {
        const enabledPrivateSpace = $privateSpace.find("input[type='checkbox']").prop("checked");
        $isTransparent.find("input[type='checkbox']").attr("disabled", "disabled");
        $specialFeatures.hide();

        if (enabledPrivateSpace) {
          $isTransparent.find("input[type='checkbox']").attr("disabled", !enabledPrivateSpace);
          $specialFeatures.show();
        }
      };

      $privateSpace.on("change", toggleDisabledHiddenFields);
      toggleDisabledHiddenFields();

      const $assemblyType = $form.find("#assembly_assembly_type");
      const $assemblyTypeOther = $form.find("#assembly_type_other");

      const $assemblyCreatedBy = $form.find("#assembly_created_by");
      const $assemblyCreatedByOther = $form.find("#created_by_other");

      const toggleDependsOnSelect = ($target, $showDiv) => {
        const value = $target.val();
        $showDiv.hide();
        if (value === "others") {
          $showDiv.show();
        }
      };

      $assemblyType.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $assemblyTypeOther);
      });

      $assemblyCreatedBy.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $assemblyCreatedByOther);
      });

      toggleDependsOnSelect($assemblyType, $assemblyTypeOther);
      toggleDependsOnSelect($assemblyCreatedBy, $assemblyCreatedByOther);
    }

  })(window);
});
