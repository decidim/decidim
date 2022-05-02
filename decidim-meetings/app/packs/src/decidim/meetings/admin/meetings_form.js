import AutoButtonsByPositionComponent from "src/decidim/admin/auto_buttons_by_position.component"
import AutoLabelByPositionComponent from "src/decidim/admin/auto_label_by_position.component"
import createSortList from "src/decidim/admin/sort_list.component"
import createDynamicFields from "src/decidim/admin/dynamic_fields.component"
import createFieldDependentInputs from "src/decidim/admin/field_dependent_inputs.component"
import attachGeocoding from "src/decidim/geocoding/attach_input"

$(() => {
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

    attachGeocoding($form.find("#meeting_address"));

    const $meetingRegistrationType = $form.find("#meeting_registration_type");
    const $meetingRegistrationUrl = $form.find("#meeting_registration_url");

    const toggleDependsOnSelect = ($target, $showDiv, type) => {
      const value = $target.val();
      $showDiv.toggle(value === type);
    };

    $meetingRegistrationType.on("change", (ev) => {
      const $target = $(ev.target);
      toggleDependsOnSelect($target, $meetingRegistrationUrl, "on_different_platform");
    });

    toggleDependsOnSelect($meetingRegistrationType, $meetingRegistrationUrl, "on_different_platform");

    const $meetingTypeOfMeeting = $form.find("#meeting_type_of_meeting");
    const $meetingOnlineFields = $form.find(".field[data-meeting-type='online']");
    const $meetingInPersonFields = $form.find(".field[data-meeting-type='in_person']");
    const $meetingOnlineAccessLevelFields = $form.find(".field[data-meeting-type='online-access-level']");
    const $meetingIframeEmbedType = $form.find("#meeting_iframe_embed_type");

    const toggleTypeDependsOnSelect = ($target, $showDiv, type) => {
      const value = $target.val();
      if (value === "hybrid") {
        $showDiv.show();
      } else {
        $showDiv.hide();
        if (value === type) {
          $showDiv.show();
        }
      }
    };

    $meetingTypeOfMeeting.on("change", (ev) => {
      const $target = $(ev.target);
      const embedTypeValue = $("#meeting_iframe_embed_type select").val();

      toggleTypeDependsOnSelect($target, $meetingOnlineFields, "online");
      toggleTypeDependsOnSelect($target, $meetingInPersonFields, "in_person");
      if (embedTypeValue === "none") {
        $meetingOnlineAccessLevelFields.hide();
      } else {
        toggleTypeDependsOnSelect($target, $meetingOnlineAccessLevelFields, "online");
      }
    });

    toggleTypeDependsOnSelect($meetingTypeOfMeeting, $meetingOnlineFields, "online");
    toggleTypeDependsOnSelect($meetingTypeOfMeeting, $meetingInPersonFields, "in_person");
    createFieldDependentInputs({
      controllerField: $meetingIframeEmbedType,
      wrapperSelector: ".iframe-fields",
      dependentFieldsSelector: ".iframe-fields--access-level",
      dependentInputSelector: "input",
      enablingCondition: ($field) => {
        return $field.find("select").val() !== "none"
      }
    });
  }
})
