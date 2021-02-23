((exports) => {
  exports.$(() => {
    const timeOuter = (interval) => {
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

      const sessionTimeLeft = () => {
        return $.ajax({
          method: "GET",
          url: secondsUntilTimeoutPath,
          contentType: "application/json",
          headers: {
            "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
          },
          complete: (_jqXHR, textStatus) => {
            $("#test_element").append(`Request status: ${textStatus}`)
          }
        })
        // $("#test_element").append("TIME LEFT ASKING DONE<br>");
        // $("#test_element").append(`${JSON.stringify(result)}<br>`);
        // return result.seconds_remaining
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

      const exitInterval = setInterval(() => {
        console.log("START INTERVAL", exports.moment())
        const diff = endsAt - exports.moment();
        const diffInSeconds = Math.round(diff / 1000);
        $("#test_element").append(`dfscnds: ${diffInSeconds}<br>`);
        if (diffInSeconds > 150) {
          return;
        }

        sessionTimeLeft().then((result) => {
          const secondsUntilSessionExpires = result.seconds_remaining;
          setTimer(secondsUntilSessionExpires)

          $("#test_element").append(`secondsUntilSessionExpires: ${secondsUntilSessionExpires}<br>`);
          if (secondsUntilSessionExpires <= 90) {
            // $("#test_element").append(`<p style={color: red}>SIGNED OUT You were inactive for too long: ${secondsUntilSessionExpires}</p>`);
            $timeoutModal.find("#reveal-hidden-sign-out")[0].click();
          } else if (secondsUntilSessionExpires <= 150) {
            popup.open();
          }
        });
      }, interval);

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
    }

    timeOuter(10000);

    exports.Decidim.timeouter = timeOuter;
  })
})(window)
