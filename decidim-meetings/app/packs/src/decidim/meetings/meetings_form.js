import attachGeocoding from "src/decidim/geocoding/attach_input"
import createFieldDependentInputs from "src/decidim/admin/field_dependent_inputs.component"

$(() => {
  // Adds the latitude/longitude inputs after the geocoding is done
  const $meetingAddress = $("#meeting_address");
  if ($meetingAddress.length > 0) {
    attachGeocoding($meetingAddress);
  }

  const $form = $(".meetings_form");
  if ($form.length > 0) {
    const $meetingTypeOfMeeting = $form.find("#meeting_type_of_meeting");
    const $meetingOnlineFields = $form.find(".field[data-meeting-type='online']");
    const $meetingInPersonFields = $form.find(".field[data-meeting-type='in_person']");
    const $meetingOnlineAccessLevelFields = $form.find(".field[data-meeting-type='online-access-level']");

    const toggleDependsOnSelect = ($target, $showDiv, type) => {
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
      const embedTypeValue = $("#meeting_iframe_embed_type").val();

      toggleDependsOnSelect($target, $meetingOnlineFields, "online");
      toggleDependsOnSelect($target, $meetingInPersonFields, "in_person");
      if (embedTypeValue === "none") {
        $meetingOnlineAccessLevelFields.hide();
      } else {
        toggleDependsOnSelect($target, $meetingOnlineAccessLevelFields, "online");
      }
    });

    toggleDependsOnSelect($meetingTypeOfMeeting, $meetingOnlineFields, "online");
    toggleDependsOnSelect($meetingTypeOfMeeting, $meetingInPersonFields, "in_person");


    const $meetingRegistrationType = $form.find("#meeting_registration_type");
    const $meetingRegistrationTerms = $form.find("#meeting_registration_terms");
    const $meetingRegistrationUrl = $form.find("#meeting_registration_url");
    const $meetingAvailableSlots = $form.find("#meeting_available_slots");

    $meetingRegistrationType.on("change", (ev) => {
      const $target = $(ev.target);
      toggleDependsOnSelect($target, $meetingAvailableSlots, "on_this_platform");
      toggleDependsOnSelect($target, $meetingRegistrationTerms, "on_this_platform");
      toggleDependsOnSelect($target, $meetingRegistrationUrl, "on_different_platform");
    });

    toggleDependsOnSelect($meetingRegistrationType, $meetingAvailableSlots, "on_this_platform");
    toggleDependsOnSelect($meetingRegistrationType, $meetingRegistrationTerms, "on_this_platform");
    toggleDependsOnSelect($meetingRegistrationType, $meetingRegistrationUrl, "on_different_platform");

    createFieldDependentInputs({
      controllerField: $("#meeting_iframe_embed_type"),
      wrapperSelector: ".iframe-fields",
      dependentFieldsSelector: ".iframe-fields--access-level",
      dependentInputSelector: "input",
      enablingCondition: ($field) => {
        return $field.val() !== "none"
      }
    });
  }
});
