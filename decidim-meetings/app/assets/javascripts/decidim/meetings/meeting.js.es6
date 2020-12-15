((exports) => {
  const { createJitsiMeetVideoConference } = exports.Decidim;
  const wrapperSelector = "#jitsi-embedded-meeting";

  let state = {
    event: null,
    userVideoconferenceId: null
  };

  $(document).ready(() => {
    const attendanceUrl = $(wrapperSelector).data("attendanceUrl");

    const onVideoConferenceJoined = (data) => {
      state.userVideoconferenceId = data.id;
      state.event = "join";
      data.event = "join";

      $.post(attendanceUrl, data);
    }

    const onVideoConferenceLeave = (data) => {
      if (state.event === "join") {
        $.post(attendanceUrl, { roomName: data.roomName, id: state.userVideoconferenceId, event: "leave" });
      }

      state.event = "leave";
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
      $(".videoconference .help").addClass("hide");
      joinVideoConference();
    });
  });

})(window);
