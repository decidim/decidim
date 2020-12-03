((exports) => {
  const { createJitsiMeetVideoConference } = exports.Decidim;
  const onVideoConferenceLeave = () => {
    $("#jitsi-embedded-meeting").remove();
    $("#videoconference-closed-message").removeClass("hide");
  }

  createJitsiMeetVideoConference({
    wrapper: $("#jitsi-embedded-meeting"),
    onVideoConferenceLeave: onVideoConferenceLeave
  });

})(window);
