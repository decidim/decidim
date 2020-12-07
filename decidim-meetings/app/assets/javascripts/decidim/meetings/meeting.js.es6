((exports) => {
  const { createJitsiMeetVideoConference } = exports.Decidim;
  const onVideoConferenceLeave = () => {
    $("#jitsi-embedded-meeting").remove();
    $("#videoconference-closed-message").removeClass("hide");
  }

  const joinVideoConference = () => {
    const wrapper = $("#jitsi-embedded-meeting");
    wrapper.removeClass("hide");
    createJitsiMeetVideoConference({
      wrapper: wrapper,
      onVideoConferenceLeave: onVideoConferenceLeave
    });
  }

  $(document).ready(() => {
    $("#join-videoconference").on("click", (event) => {
      $(event.target).addClass("hide");
      joinVideoConference();
    });
  });

})(window);
