((exports) => {
  const { AutoButtonsByPositionComponent, AutoLabelByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;

  const dynamicFieldDefinitions = [
    {
      placeHolderId: "external-domain-id",
      wrapperSelector: ".external-domains",
      fieldSelector: ".external-domain",
      addFieldSelector: ".add-external-domain"
    }
  ];

  dynamicFieldDefinitions.forEach((section) => {
    const fieldSelectorSuffix = section.fieldSelector.replace(".", "");

    const autoButtonsByPosition = new AutoButtonsByPositionComponent({
      listSelector: `${section.fieldSelector}:not(.hidden)`,
      hideOnFirstSelector: ".move-up-question",
      hideOnLastSelector: ".move-down-question"
    });

    const autoLabelByPosition = new AutoLabelByPositionComponent({
      listSelector: `${section.fieldSelector}:not(.hidden)`,
      labelSelector: ".card-title span:first",
      onPositionComputed: (el, idx) => {
        $(el).find("input[name$=\\[position\\]]").val(idx);
      }
    });

    const createSortableList = () => {
      createSortList(".external-domains-list:not(.published)", {
        handle: ".external-domain-divider",
        placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
        forcePlaceholderSize: true,
        onSortUpdate: () => {
          autoLabelByPosition.run();
          autoButtonsByPosition.run();
        }
      });
    };

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
      moveUpFieldButtonSelector: ".move-up-question",
      moveDownFieldButtonSelector: ".move-down-question",
      onAddField: () => {
        createSortableList();

        autoLabelByPosition.run();
        autoButtonsByPosition.run();
      },
      onRemoveField: ($field) => {
        autoLabelByPosition.run();
        autoButtonsByPosition.run();

        // Allows re-submitting of the form
        $("input", $field).removeAttr("required");
      },
      onMoveUpField: () => {
        autoLabelByPosition.run();
        autoButtonsByPosition.run();
      },
      onMoveDownField: () => {
        autoLabelByPosition.run();
        autoButtonsByPosition.run();
      }
    });

    createSortableList();

    $(section.fieldSelector).each((_idx, el) => {
      const $target = $(el);

      hideDeletedItem($target);
    });

    autoLabelByPosition.run();
    autoButtonsByPosition.run();
  });
})(window);
