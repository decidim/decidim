((exports) => {
  exports.$(() => {
    const Foundation = exports.Foundation;
    const $timeoutModal = $("#timeoutModal")
    const sessionTime = $timeoutModal.attr("data-session-timeout")
    let endsAt = exports.moment().add(sessionTime, "seconds")
    const popup = new Foundation.Reveal($timeoutModal);
    const $continueSessionButton = $("#continueSession")

    const calculateEndingTime = () => {
      return endsAt - exports.moment();
    }

    const resetTimer = () => {
      endsAt = exports.moment().add(sessionTime, "seconds")
    }

    // Ajax request is made at timeout_modal.html.erb
    $continueSessionButton.on("click", () => {
      $("#timeoutModal").foundation("close")
      // In admin panel we have to hide all overlays
      $(".reveal-overlay").css("display", "none");
    })

    if (!sessionTime) {
      return;
    }

    const exitInterval = setInterval(() => {
      const diff = calculateEndingTime();
      const diffInMinutes = Math.round(diff / 60000);

      if (diffInMinutes <= 1) {
        $timeoutModal.find("#reveal-hidden-sign-out")[0].click();
      } else if (diffInMinutes <= 2) {
        $("#timeoutModal").foundation("open");
        popup.open();
      }
    }, 10000);

    // Devise restarts its own timer on ajax requests,
    // so here we restart our.
    $(document).on("ajax:complete", () => {
      resetTimer();
    });

    $(document).ajaxComplete(() => {
      resetTimer();
    });

    window.addEventListener("beforeunload", () => {
      clearInterval(exitInterval);
      return;
    });
  })
})(window)
