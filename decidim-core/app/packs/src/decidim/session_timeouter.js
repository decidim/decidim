import moment from "moment"
import Foundation from "foundation-sites"

$(() => {
  let sessionTimeOutEnabled = true;
  const $timeoutModal = $("#timeoutModal");
  const timeoutInSeconds = parseInt($timeoutModal.data("session-timeout"), 10);
  const secondsUntilTimeoutPath = $timeoutModal.data("seconds-until-timeout-path");
  const heartbeatPath = $timeoutModal.data("heartbeat-path");
  const interval = parseInt($timeoutModal.data("session-timeout-interval"), 10);
  const preventTimeOutSeconds = $timeoutModal.data("prevent-timeout-seconds");
  let endsAt = moment().add(timeoutInSeconds, "seconds");
  let lastAction = moment();
  const popup = new Foundation.Reveal($timeoutModal);
  const $continueSessionButton = $("#continueSession");
  let lastActivityCheck = moment();
  // 5 * 60 seconds = 5 Minutes
  const activityCheckInterval = 5 * 60;
  const preventTimeOutUntil = moment().add(preventTimeOutSeconds, "seconds");

  // Ajax request is made at timeout_modal.html.erb
  $continueSessionButton.on("click", () => {
    $("#timeoutModal").foundation("close");
    // In admin panel we have to hide all overlays
    $(".reveal-overlay").css("display", "none");
    lastActivityCheck = moment();
  })

  if (isNaN(interval)) {
    return;
  }
  if (!timeoutInSeconds) {
    return;
  }

  const disableSessionTimeout = () => {
    sessionTimeOutEnabled = false;
  }

  const enableSessionTimeout = () => {
    sessionTimeOutEnabled = true;
  }

  const setTimer = (secondsUntilExpiration) => {
    if (!secondsUntilExpiration) {
      return;
    }
    endsAt = moment().add(secondsUntilExpiration, "seconds");
  }

  const sessionTimeLeft = () => {
    return $.ajax({
      method: "GET",
      url: secondsUntilTimeoutPath,
      contentType: "application/json",
      headers: {
        "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
      }
    });
  }

  const heartbeat = () => {
    return $.ajax({
      method: "POST",
      url: heartbeatPath,
      contentType: "application/javascript"
    });
  }

  const userBeenActiveSince = (seconds) => {
    return (moment() - lastAction) / 1000 < seconds;
  }

  const exitInterval = setInterval(() => {
    const timeSinceLastActivityCheckInSeconds = Math.round((moment() - lastActivityCheck) / 1000);

    const popupOpen = $("#timeoutModal").parent().css("display") === "block";
    if (!popupOpen && timeSinceLastActivityCheckInSeconds >= activityCheckInterval) {
      lastActivityCheck = moment();
      if (userBeenActiveSince(activityCheckInterval)) {
        heartbeat();
        return;
      }
    }

    const timeRemaining = Math.round((endsAt - moment()) / 1000);
    if (timeRemaining > 150) {
      return;
    }

    if (moment() < preventTimeOutUntil) {
      heartbeat();
      return;
    }

    sessionTimeLeft().then((result) => {
      const secondsUntilSessionExpires = result.seconds_remaining;
      setTimer(secondsUntilSessionExpires);

      if (!sessionTimeOutEnabled) {
        heartbeat();
      } else if (secondsUntilSessionExpires <= 90) {
        $timeoutModal.find("#reveal-hidden-sign-out")[0].click();
      } else if (secondsUntilSessionExpires <= 150) {
        popup.open();
      }
    });
  }, interval);

  $(document).mousemove(() => {
    lastAction = moment();
  })
  $(document).scroll(() => {
    lastAction = moment();
  })
  $(document).keypress(() => {
    lastAction = moment();
  })

  // Devise restarts its own timer on ajax requests,
  // so here we restart our.
  $(document).on("ajax:complete", () => {
    setTimer(timeoutInSeconds);
  });

  $(document).ajaxComplete((_event, _xhr, settings) => {
    if (settings && settings.url === secondsUntilTimeoutPath) {
      return;
    }
    setTimer(timeoutInSeconds);
  });

  window.addEventListener("beforeunload", () => {
    clearInterval(exitInterval);
    return;
  });

  window.Decidim.enableSessionTimeout = enableSessionTimeout
  window.Decidim.disableSessionTimeout = disableSessionTimeout
});
