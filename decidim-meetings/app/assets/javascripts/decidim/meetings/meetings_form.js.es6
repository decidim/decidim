((exports) => {
  const $ = exports.$; // eslint-disable-line
  const { attachGeocoding } = exports.Decidim;

  $(() => {
    // Adds the latitude/longitude inputs after the geocoding is done
    attachGeocoding($("#meeting_address"));

    const $form = $(".meetings_form");
    if ($form.length > 0) {
      const $meetingTypeOfMeeting = $form.find("#meeting_type_of_meeting");
      const $meetingAddress = $form.find("#address");
      const $meetingLocation = $form.find("#location");
      const $meetingOnlineMeetingUrl = $form.find("#meeting_online_meeting_url")

      const toggleDependsOnSelect = ($target, $showDiv, type) => {
        const value = $target.val();
        $showDiv.hide();
        if (value === type) {
          $showDiv.show();
        }
      };

      $meetingTypeOfMeeting.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingLocation, "in_person");
        toggleDependsOnSelect($target, $meetingAddress, "in_person");
        toggleDependsOnSelect($target, $meetingOnlineMeetingUrl, "online");
      });

      toggleDependsOnSelect($meetingTypeOfMeeting, $meetingLocation, "in_person");
      toggleDependsOnSelect($meetingTypeOfMeeting, $meetingAddress, "in_person");
      toggleDependsOnSelect($meetingTypeOfMeeting, $meetingOnlineMeetingUrl, "online");
    }
  });
})(window);
