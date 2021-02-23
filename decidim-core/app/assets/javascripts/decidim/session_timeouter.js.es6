((exports) => {
  exports.$(() => {
    const Foundation = exports.Foundation;
    const $timeoutModal = $("#timeoutModal")
    const sessionTimeOutInSeconds = $timeoutModal.attr("data-session-timeout")
    const secondsUntilTimeoutPath = $timeoutModal.attr("data-seconds-until-timeout-path")
    let endsAt = exports.moment().add(sessionTimeOutInSeconds, "seconds")
    const popup = new Foundation.Reveal($timeoutModal);
    const $continueSessionButton = $("#continueSession")

    const setTimer = (secondsUntilExpiration) => {
      if (!secondsUntilExpiration) {
        return;
      }
      endsAt = exports.moment().add(secondsUntilExpiration, "seconds")
    }

    const sessionTimeLeft = async () => {
      const result = await $.ajax({
        method: "GET",
        url: secondsUntilTimeoutPath,
        contentType: "application/json",
        headers: {
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      });
      return result.seconds_remaining
    }

    // Ajax request is made at timeout_modal.html.erb
    $continueSessionButton.on("click", () => {
      $("#timeoutModal").foundation("close")
      // In admin panel we have to hide all overlays
      $(".reveal-overlay").css("display", "none");
    })

    if (!sessionTimeOutInSeconds) {
      return;
    }

    const exitInterval = setInterval(async () => {
      const diff = endsAt - exports.moment();
      const diffInSeconds = Math.round(diff / 1000);

      if (diffInSeconds <= 90) {
        $timeoutModal.find("#reveal-hidden-sign-out")[0].click();
      } else if (diffInSeconds <= 150) {
        const secondsUntilSessionExpires = await sessionTimeLeft();
        setTimer(secondsUntilSessionExpires)
        if (secondsUntilSessionExpires <= 150) {
          popup.open();
        }
      }
    }, 10000);

    // Devise restarts its own timer on ajax requests,
    // so here we restart our.
    $(document).on("ajax:complete", () => {
      setTimer(sessionTimeOutInSeconds);
    });

    $(document).ajaxComplete((_event, _xhr, settings) => {
      if (settings && settings.url === secondsUntilTimeoutPath) {
        return;
      }
      setTimer(sessionTimeOutInSeconds);
    });

    window.addEventListener("beforeunload", () => {
      clearInterval(exitInterval);
      return;
    });
  })
})(window)
