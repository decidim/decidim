/* eslint-disable no-undef */
((exports) => {
  class JitsiMeetVideoConference {
    constructor(options = {}) {
      this.$wrapper = options.wrapper;
      this.onVideoConferenceLeave = options.onVideoConferenceLeave;
      this._run();
    }

    _run() {
      const $wrapper = this.$wrapper;

      const roomName = $wrapper.data("roomName");
      const domain = $wrapper.data("domain") || "meet.jit.si";
      const apiUrl = $wrapper.data("apiUrl") || "https://meet.jit.si/external_api.js";

      const height = $wrapper.data("height") || 600;

      const userEmail = $wrapper.data("userEmail");
      const userDisplayName = $wrapper.data("userDisplayName");
      const userIsVisitor = $wrapper.data("userIsVisitor") || false;

      const startWithAudioMuted = $wrapper.data("startWithAudioMuted") || userIsVisitor;
      const startWithVideoMuted = $wrapper.data("startWithVideoMuted") || userIsVisitor;

      const enableInvite = $wrapper.data("enableInvite") || false;

      const onVideoConferenceLeave = this.onVideoConferenceLeave;

      let toolbarButtons = [
        "microphone", "camera", "closedcaptions", "desktop", "embedmeeting", "fullscreen",
        "fodeviceselection", "hangup", "profile", "chat", "recording",
        "livestreaming", "etherpad", "sharedvideo", "settings", "raisehand",
        "videoquality", "filmstrip", "feedback", "stats", "shortcuts",
        "tileview", "videobackgroundblur", "download", "help", "mute-everyone", "security"
      ];

      if (enableInvite) {
        toolbarButtons.push("invite");
      }

      const options = {
        roomName: roomName,
        height: height,
        parentNode: $wrapper[0],
        interfaceConfigOverwrite: {
          SHOW_JITSI_WATERMARK: false,
          HIDE_INVITE_MORE_HEADER: true,
          TOOLBAR_BUTTONS: toolbarButtons
        },
        configOverwrite: {
          disableInviteFunctions: true,
          disableSimulcast: false,
          // enableWelcomePage: false,
          // prejoinPageEnabled: false,
          // startAudioMuted: 1,
          startWithAudioMuted: startWithAudioMuted,
          // startVideoMuted: 1,
          startWithVideoMuted: startWithVideoMuted
        },
        userInfo: {
          email: userEmail,
          displayName: userDisplayName
        }
      }

      $.getScript(apiUrl).
        done(function() {
          const api = new JitsiMeetExternalAPI(domain, options);
          api.addEventListener("videoConferenceLeft", onVideoConferenceLeave);
        }).
        fail(function() {
          $wrapper.appendElement("<p class=\"callout alert\">Jitsi Meet Videoconference could not be loaded</p>");
        });

    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.createJitsiMeetVideoConference = (options) => {
    return new JitsiMeetVideoConference(options);
  };
})(window);
