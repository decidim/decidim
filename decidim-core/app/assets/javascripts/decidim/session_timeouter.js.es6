// = require foundation

((exports) => {
  exports.$(() => {
    const Foundation = exports.Foundation;
    const $myModal = jQuery("#timeoutModal")
    const sessionTime = $myModal.attr("data-session-timeout")
    let endsAt = exports.moment().add(sessionTime, "seconds")
    const popup = new Foundation.Reveal($myModal);
    const $continueSessionButton = $("#continueSession")
    const timeOutMessage = $myModal.attr("data-timeout-message")

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

      console.log("Difference in minutes", diffInMinutes)
      // console.log("signOutLink", $signOutLink)

      if (diffInMinutes <= 9) {
        $.ajax({
          method: "DELETE",
          url: "/users/sign_out",
          data: JSON.stringify({ timeout: "true" }),
          contentType: "application/json",
          headers: {
            "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
          },
          success: () => {
            document.location.href = "/users/sign_in";
          }
        })
      } else if (diffInMinutes <= 10) {
        // jQuery("#timeoutModal").foundation("open")
        $("#timeoutModal").foundation("open");
        popup.open();
      }
    }, 10000);

    // Set ajax events
    $(document).on("ajax:complete", () => {
      console.log("AJAX")
      resetTimer();
    });

    $(document).ajaxComplete(() => {
      console.log("AJAX2")
      resetTimer();
    });

    window.onbeforeunload = () => {
      clearInterval(exitInterval);
    };
  })
})(window)
