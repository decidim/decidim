((exports) => {
  exports.$(() => {
    const Foundation = exports.Foundation;
    const $timeoutModal = $("#timeoutModal")
    const sessionTimeOutInSeconds = $timeoutModal.attr("data-session-timeout")
    const secondsUntilTimeoutPath = $timeoutModal.attr("data-seconds-until-timeout-path")
    let endsAt = exports.moment().add(sessionTimeOutInSeconds, "seconds")
    const popup = new Foundation.Reveal($timeoutModal);
    const $continueSessionButton = $("#continueSession")

    const resetTimer = (secondsUntilExpiration) => {
      endsAt = exports.moment().add(secondsUntilExpiration, "seconds")
    }

    const sessionTimeLeft = async () => {
      $("#test_element").append("Asking how much time is left<br>");
      const result = await $.ajax({
        method: "GET",
        url: secondsUntilTimeoutPath,
        contentType: "application/json",
        headers: {
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        },
        complete: (jqXHR, textStatus) => {
          $("#test_element").append(`Request status: ${textStatus}<br>`);
        }
      });
      $("#test_element").append("TIME LEFT ASKING DONE<br>");
      $("#test_element").append(`${JSON.stringify(result)}<br>`);
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

      console.log("diffInSeconds", diffInSeconds)
      $("#test_element").append(`DIFF IN SECONDS: ${diffInSeconds}<br>`);
      $("#test_element").append("Hello from the exitInterval<br>");
      if (diffInSeconds <= 90) {
        $timeoutModal.find("#reveal-hidden-sign-out")[0].click();
      } else if (diffInSeconds <= 150) {
        const secondsUntilSessionExpires = await sessionTimeLeft();
        console.log("secondsUntilSessionExpires", secondsUntilSessionExpires)
        if (secondsUntilSessionExpires <= 150) {
          popup.open();
        } else {
          resetTimer(secondsUntilSessionExpires)
        }
      }
    }, 10000);

    // Devise restarts its own timer on ajax requests,
    // so here we restart our.
    $(document).on("ajax:complete", () => {
      resetTimer(sessionTimeOutInSeconds);
    });

    $(document).ajaxComplete((_event, _xhr, settings) => {
      if (settings && settings.url === "/session_seconds_until_timeout") {
        return;
      }
      resetTimer(sessionTimeOutInSeconds);
    });

    window.addEventListener("beforeunload", () => {
      clearInterval(exitInterval);
      return;
    });
  })
})(window)
