// = require foundation

((exports) => {
  exports.$(() => {
    const Foundation = exports.Foundation;
    const $timeoutModal = $("#timeoutModal")
    const sessionTime = $timeoutModal.attr("data-session-timeout")
    let endsAt = exports.moment().add(sessionTime, "seconds")
    const popup = new Foundation.Reveal($timeoutModal);
    const $continueSessionButton = $("#continueSession")
    const timeOutMessage = $timeoutModal.attr("data-timeout-message")

    const calculateEndingTime = () => {
      return endsAt - exports.moment();
    }

    const resetTimer = () => {
      endsAt = exports.moment().add(sessionTime, "seconds")
    }

    // Ajax request is made at timeout_modal.html.erb
    $continueSessionButton.on("click", () => {
      $("#timeoutModal").foundation("close")
      // In admin panel we have to hide all overlays..
      $(".reveal-overlay").css("display", "none");
    })

    console.log("sessionTime", sessionTime)
    console.log("timeOutMessage", timeOutMessage)

    if (!sessionTime) {
      return;
    }

    const exitInterval = setInterval(() => {
      const diff = calculateEndingTime();
      const diffInMinutes = Math.round(diff / 60000);

      if (diffInMinutes <= 9) {
        $timeoutModal.find("#reveal-hidden-sign-out")[0].click();
      } else if (diffInMinutes <= 10) {
        $("#timeoutModal").foundation("open");
        popup.open();
      }
    }, 10000);

    // Set ajax events
    $(document).on("ajax:complete", () => {
      resetTimer();
    });

    $(document).ajaxComplete(() => {
      resetTimer();
    });

    window.onbeforeunload = () => {
      clearInterval(exitInterval);
    };
  })
})(window)
