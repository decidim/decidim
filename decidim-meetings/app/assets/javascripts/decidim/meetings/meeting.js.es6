((exports) => {
  const { createJitsiMeetVideoConference } = exports.Decidim;
  const onVideoConferenceLeave = () => {
    $("#videoconference-container").remove();
    $("#videoconference-closed-message").removeClass("hide");
  }

  createJitsiMeetVideoConference({
    wrapper: $("#jitsi-embedded-meeting"),
    onVideoConferenceLeave: onVideoConferenceLeave
  });

})(window);
