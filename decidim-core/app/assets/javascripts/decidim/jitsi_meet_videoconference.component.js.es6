/* eslint-disable no-undef */
((exports) => {
  class JitsiMeetVideoConference {
    constructor(options = {}) {
      this.$wrapper = options.wrapper;
      this.onVideoConferenceJoined = options.onVideoConferenceJoined;
      this.onVideoConferenceLeave = options.onVideoConferenceLeave;
      this._run();
    }

    _userIsAdmin(role) {
      return role === "admin";
    }

    _userIsVisitor(role) {
      return role === "visitor";
    }

    _run() {
      const $wrapper = this.$wrapper;

      const roomName = $wrapper.data("roomName");
      const domain = $wrapper.data("domain") || "meet.jit.si";
      const apiUrl = $wrapper.data("apiUrl") || "https://meet.jit.si/external_api.js";
      
      const height = $wrapper.data("height") || 600;

      const userEmail = $wrapper.data("userEmail");
      const userDisplayName = $wrapper.data("userDisplayName");
      const userRole = $wrapper.data("userRole");

      const isAdmin = this._userIsAdmin(userRole);
      const isVisitor = this._userIsVisitor(userRole);

      const startWithAudioMuted = $wrapper.data("startWithAudioMuted") || isVisitor;
      const startWithVideoMuted = $wrapper.data("startWithVideoMuted") || isVisitor;

      const enableInvite = $wrapper.data("enableInvite");

      const onVideoConferenceJoined = this.onVideoConferenceJoined;
      const onVideoConferenceLeave = this.onVideoConferenceLeave;

      let toolbarButtons = [
        "chat", "closedcaptions", "fullscreen",
        "fodeviceselection", "etherpad",
        "videoquality", "filmstrip", "shortcuts",
        "videobackgroundblur", "download", "help"
      ];

      const fullControlButtons = [
        "mute-everyone", "recording", "livestreaming", "sharedvideo", "embedmeeting", "stats", "settings", "security"
      ];

      const userControlButtons = [
        "camera", "microphone", "raisehand", "videobackgroundblur", "hangup", "profile", "feedback", "desktop", "tileview"
      ];

      if (isAdmin) {
        toolbarButtons = toolbarButtons.concat(fullControlButtons);
      }

      if (!isVisitor) {
        toolbarButtons = toolbarButtons.concat(userControlButtons);
      }

      if (enableInvite) {
        toolbarButtons.push("invite");
      }

      const options = {
        roomName: roomName,
        height: height,
        parentNode: $wrapper[0],
        interfaceConfigOverwrite: {
          SHOW_JITSI_WATERMARK: false,
          HIDE_INVITE_MORE_HEADER: !enableInvite,
          TOOLBAR_BUTTONS: toolbarButtons
        },
        configOverwrite: {
          disableInviteFunctions: true,
          disableSimulcast: false,
          // enableWelcomePage: !isVisitor,
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
          api.addEventListener("videoConferenceJoined", onVideoConferenceJoined);
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
