((exports) => {
  const { AutoLabelByPositionComponent, createDynamicFields } = exports.DecidimAdmin;
  console.log("JAVASCRIPT LOADED")

  const dynamicFieldDefinitions = [
    {
      placeHolderId: "url-id",
      wrapperSelector: ".recipient-group-recipients",
      fieldSelector: ".feedback-recipient",
      addFieldSelector: ".add-recipient"
    }
  ];

  dynamicFieldDefinitions.forEach((section) => {
    const fieldSelectorSuffix = section.fieldSelector.replace(".", "");

    const autoLabelByPosition = new AutoLabelByPositionComponent({
      listSelector: `${section.fieldSelector}:not(.hidden)`,
      labelSelector: ".card-title span:first",
      onPositionComputed: (el, idx) => {
        $(el).find("input[name$=\\[position\\]]").val(idx);
      }
    });

    const hideDeletedItem = ($target) => {
      const inputDeleted = $target.find("input[name$=\\[deleted\\]]").val();

      if (inputDeleted === "true") {
        $target.addClass("hidden");
        $target.hide();

        // Allows re-submitting of the form
        $("input", $target).removeAttr("required");
      }
    };

    createDynamicFields({
      placeholderId: section.placeHolderId,
      wrapperSelector: section.wrapperSelector,
      containerSelector: `${section.wrapperSelector}-list`,
      fieldSelector: section.fieldSelector,
      addFieldButtonSelector: section.addFieldSelector,
      removeFieldButtonSelector: `.remove-${fieldSelectorSuffix}`,
      onAddField: () => {
        autoLabelByPosition.run();
      },
      onRemoveField: ($field) => {
        autoLabelByPosition.run();

        // Allows re-submitting of the form
        $("input", $field).removeAttr("required");
      }
    });

    $(section.fieldSelector).each((_idx, el) => {
      const $target = $(el);

      hideDeletedItem($target);
    });

    autoLabelByPosition.run();
  });
})(window);
