((exports) => {
  const { createJitsiMeetVideoConference } = exports.Decidim;
  const wrapperSelector = "#jitsi-embedded-meeting";
  let userVideoconferenceId = null;

  $(document).ready(() => {
    const attendanceUrl = $(wrapperSelector).data("attendanceUrl");

    const onVideoConferenceJoined = (data) => {
      userVideoconferenceId = data.id;

      data.event = "join";

      $.post(attendanceUrl, data);
    }

    const onVideoConferenceLeave = (roomName) => {
      $.post(attendanceUrl, { roomName: roomName, id: userVideoconferenceId, event: "leave" });

      $(wrapperSelector).remove();
      $("#videoconference-closed-message").removeClass("hide");
    }

    const joinVideoConference = () => {
      $(wrapperSelector).removeClass("hide");

      createJitsiMeetVideoConference({
        wrapper: $(wrapperSelector),
        onVideoConferenceLeave: onVideoConferenceLeave,
        onVideoConferenceJoined: onVideoConferenceJoined
      });
    }
    $("#join-videoconference").on("click", (event) => {
      $(event.target).addClass("hide");
      joinVideoConference();
    });
  });

})(window);
