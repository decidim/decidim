((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;

  const wrapperSelector = ".meeting-services";
  const fieldSelector = ".meeting-service";

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".meeting-service:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".meeting-service:not(.hidden)",
    hideOnFirstSelector: ".move-up-service",
    hideOnLastSelector: ".move-down-service"
  });

  const createSortableList = () => {
    createSortList(".meeting-services-list:not(.published)", {
      handle: ".service-divider",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => { autoLabelByPosition.run() }
    });
  };

  const hideDeletedService = ($target) => {
    const inputDeleted = $target.find("input[name$=\\[deleted\\]]").val();

    if (inputDeleted === "true") {
      $target.addClass("hidden");
      $target.hide();
    }
  };

  createDynamicFields({
    placeholderId: "meeting-service-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".meeting-services-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-service",
    removeFieldButtonSelector: ".remove-service",
    moveUpFieldButtonSelector: ".move-up-service",
    moveDownFieldButtonSelector: ".move-down-service",
    onAddField: () => {
      createSortableList();

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

    hideDeletedService($target);
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();

  const $form = $(".edit_meeting, .new_meeting, .copy_meetings");

  if ($form.length > 0) {
    const $privateMeeting = $form.find("#private_meeting");
    const $transparent = $form.find("#transparent");

    const toggleDisabledHiddenFields = () => {
      const enabledPrivateSpace = $privateMeeting.find("input[type='checkbox']").prop("checked");
      $transparent.find("input[type='checkbox']").attr("disabled", "disabled");

      if (enabledPrivateSpace) {
        $transparent.find("input[type='checkbox']").attr("disabled", !enabledPrivateSpace);
      }
    };

    $privateMeeting.on("change", toggleDisabledHiddenFields);
    toggleDisabledHiddenFields();

    let xhr = null;

    $(".user-autocomplete").autoComplete({
      minChars: 2,
      source: function(term, response) {
        try {
          xhr.abort();
        } catch (exception) { xhr = null }

        xhr = $.getJSON(
          $(".user-autocomplete").data("url"),
          { term: term },
          function(data) { response(data); }
        );
      },
      renderItem: function (item, search) {
        let re = new RegExp(`(${search.split(" ").join("|")})`, "gi");

        let modelId = item[0];
        let name = item[1];
        let nickname = item[2];
        let val = `${name} (@${nickname})`;
        return `<div class="autocomplete-suggestion" data-model-id="${modelId}" data-val="${val}">${val.replace(re, "<b>$1</b>")}</div>`;
      },
      onSelect: function(event, term, item) {
        let modelId = item.data("modelId");
        let val = `${item.data("val")}`;
        $("#meeting_organizer_id").val(modelId);
        $(".user-autocomplete").val(val);
      }
    });
  }
})(window);
