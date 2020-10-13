((exports) => {
  const $ = exports.$; // eslint-disable-line
  const { attachGeocoding } = exports.Decidim;

  $(() => {
    // Adds the latitude/longitude inputs after the geocoding is done
    attachGeocoding($("#meeting_address"));

    const $form = $(".meetings_form");
    if ($form.length > 0) {
      const $meetingTypeOfMeeting = $form.find("#meeting_type_of_meeting");
      const $meetingOnlineFields = $form.find(".field[data-meeting-type='online']");
      const $meetingInPersonFields = $form.find(".field[data-meeting-type='in_person']");

      const toggleDependsOnSelect = ($target, $showDiv, type) => {
        const value = $target.val();
        $showDiv.hide();
        if (value === type) {
          $showDiv.show();
        }
      };

      $meetingTypeOfMeeting.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingOnlineFields, "online");
        toggleDependsOnSelect($target, $meetingInPersonFields, "in_person");
      });

      toggleDependsOnSelect($meetingTypeOfMeeting, $meetingOnlineFields, "online");
      toggleDependsOnSelect($meetingTypeOfMeeting, $meetingInPersonFields, "in_person");
    }

    const $meetingForm = $(".edit_meeting, .new_meeting");
    if ($meetingForm.length > 0) {

      const toggleDependsOnSelect = ($target, $showDiv, type) => {
        const value = $target.val();
        $showDiv.hide();
        if (value === type) {
          $showDiv.show();
        }
      };

      const $meetingRegistrationType = $meetingForm.find("#meeting_registration_type");
      const $meetingRegistrationTerms = $meetingForm.find("#meeting_registration_terms");
      const $meetingRegistrationUrl = $meetingForm.find("#meeting_registration_url");
      const $meetingAvailableSlots = $meetingForm.find("#meeting_available_slots");

      $meetingRegistrationType.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingAvailableSlots, "on_this_platform");
        toggleDependsOnSelect($target, $meetingRegistrationTerms, "on_this_platform");
        toggleDependsOnSelect($target, $meetingRegistrationUrl, "on_different_platform");
      });
  
      toggleDependsOnSelect($meetingRegistrationType, $meetingAvailableSlots, "on_this_platform");
      toggleDependsOnSelect($meetingRegistrationType, $meetingRegistrationTerms, "on_this_platform");
      toggleDependsOnSelect($meetingRegistrationType, $meetingRegistrationUrl, "on_different_platform");
    }
  });
})(window);
