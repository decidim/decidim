((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;
  const { createQuillEditor } = exports.Decidim;

  const wrapperSelector = ".meeting-agenda-items";
  const fieldSelector = ".meeting-agenda-item";
  const childsWrapperSelector = ".meeting-agenda-item-childs";
  const childFieldSelector = ".meeting-agenda-item-child";

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".meeting-agenda-item:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".meeting-agenda-item:not(.hidden)",
    hideOnFirstSelector: ".move-up-agenda-item",
    hideOnLastSelector: ".move-down-agenda-item"
  });

  const createSortableList = () => {
    createSortList(".meeting-agenda-items-list:not(.published)", {
      handle: ".agenda-item-divider",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => { autoLabelByPosition.run() }
    });
  };

  const createSortableListChild = () => {
    createSortList(".meeting-agenda-item-childs-list:not(.published)", {
      handle: ".agenda-item-child-divider",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => { autoLabelByPosition.run() }
    });
  };

  const autoLabelByPositionChild = new AutoLabelByPositionComponent({
    listSelector: ".meeting-agenda-item-child:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPositionChild = new AutoButtonsByPositionComponent({
    listSelector: ".meeting-agenda-item-child:not(.hidden)",
    hideOnFirstSelector: ".move-up-agenda-item-child",
    hideOnLastSelector: ".move-down-agenda-item-child"
  });

  const createDynamicFieldsForAgendaItemChilds = (fieldId) => {
    return createDynamicFields({
      placeholderId: "meeting-agenda-item-child-id",
      wrapperSelector: `#${fieldId} ${childsWrapperSelector}`,
      containerSelector: ".meeting-agenda-item-childs-list",
      fieldSelector: childFieldSelector,
      addFieldButtonSelector: ".add-agenda-item-child",
      removeFieldButtonSelector: ".remove-agenda-item-child",
      moveUpFieldButtonSelector: ".move-up-agenda-item-child",
      moveDownFieldButtonSelector: ".move-down-agenda-item-child",

      onAddField: ($field) => {
        createSortableListChild();

        $field.find(".editor-container").each((idx, el) => {
          createQuillEditor(el);
        });

        autoLabelByPositionChild.run();
        autoButtonsByPositionChild.run();
      },
      onRemoveField: () => {
        autoLabelByPositionChild.run();
        autoButtonsByPositionChild.run();
      },
      onMoveUpField: () => {
        autoLabelByPositionChild.run();
        autoButtonsByPositionChild.run();
      },
      onMoveDownField: () => {
        autoLabelByPositionChild.run();
        autoButtonsByPositionChild.run();
      }
    });
  };

  const dynamicFieldsForAgendaItemChilds = {};

  const setupInitialAgendaItemChildAttributes = ($target) => {
    const fieldId = $target.attr("id");

    dynamicFieldsForAgendaItemChilds[fieldId] = createDynamicFieldsForAgendaItemChilds(fieldId);

  }

  const hideDeletedAgendaItem = ($target) => {
    const inputDeleted = $target.find("input[name$=\\[deleted\\]]").val();

    if (inputDeleted === "true") {
      $target.addClass("hidden");
      $target.hide();
    }
  };

  createDynamicFields({
    placeholderId: "meeting-agenda-item-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".meeting-agenda-items-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-agenda-item",
    removeFieldButtonSelector: ".remove-agenda-item",
    moveUpFieldButtonSelector: ".move-up-agenda-item",
    moveDownFieldButtonSelector: ".move-down-agenda-item",
    onAddField: ($field) => {
      // createDynamicFieldsForAgendaItemChilds($field);
      setupInitialAgendaItemChildAttributes($field);
      createSortableList();

      $field.find(".editor-container").each((idx, el) => {
        createQuillEditor(el);
      });

      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onRemoveField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
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

  $(fieldSelector).each((idx, el) => {
    const $target = $(el);

    hideDeletedAgendaItem($target);
    setupInitialAgendaItemChildAttributes($target);
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();
  autoLabelByPositionChild.run();
  autoButtonsByPositionChild.run();
})(window);
