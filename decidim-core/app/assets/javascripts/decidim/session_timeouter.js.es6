((exports) => {
  exports.$(() => {
    const Foundation = exports.Foundation;
    const $timeoutModal = $("#timeoutModal");
    const timeoutInSeconds = parseInt($timeoutModal.data("session-timeout"), 10);
    const secondsUntilTimeoutPath = $timeoutModal.data("seconds-until-timeout-path");
    const interval = $timeoutModal.data("session-timeouter-interval");
    let endsAt = exports.moment().add(timeoutInSeconds, "seconds");
    const popup = new Foundation.Reveal($timeoutModal);
    const $continueSessionButton = $("#continueSession");

    // Ajax request is made at timeout_modal.html.erb
    $continueSessionButton.on("click", () => {
      $("#timeoutModal").foundation("close")
      // In admin panel we have to hide all overlays
      $(".reveal-overlay").css("display", "none");
    })

    if (!timeoutInSeconds) {
      return;
    }

    const setTimer = (secondsUntilExpiration) => {
      if (!secondsUntilExpiration) {
        return;
      }
      endsAt = exports.moment().add(secondsUntilExpiration, "seconds")
    }

    const sessionTimeLeft = () => {
      return $.ajax({
        method: "GET",
        url: secondsUntilTimeoutPath,
        contentType: "application/json",
        headers: {
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      })
    }

    const exitInterval = setInterval(() => {
      const diff = endsAt - exports.moment();
      const diffInSeconds = Math.round(diff / 1000);
      if (diffInSeconds > 150) {
        return;
      }

      sessionTimeLeft().then((result) => {
        const secondsUntilSessionExpires = result.seconds_remaining;
        setTimer(secondsUntilSessionExpires)

        if (secondsUntilSessionExpires <= 90) {
          $timeoutModal.find("#reveal-hidden-sign-out")[0].click();
        } else if (secondsUntilSessionExpires <= 150) {
          popup.open();
        }
      });
    }, interval);

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
  })
})(window)
