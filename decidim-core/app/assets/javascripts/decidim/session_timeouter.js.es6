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

    $continueSessionButton.on("click", () => {
      console.log("CLICK CONTINUE SESSION")
      jQuery("#timeoutModal").foundation("close")
    })

    console.log("sessionTime", sessionTime)
    console.log("timeOutMessage", timeOutMessage)

    if (sessionTime) {
      setInterval(() => {
        const diff = calculateEndingTime();
        const diffInMinutes = Math.round(diff / 60000);

        console.log("Difference in minutes", diffInMinutes)
        // console.log("signOutLink", $signOutLink)

        if (diffInMinutes === 9) {
          console.log("LOGOUTTAA")
          // document.getElementById("reveal-sign-out").click();
          // $.ajax({
          //   method: "DELETE",
          //   url: "/users/sign_out",
          //   dataType: "script",
          //   contentType: "application/javascript",
          //   headers: {
          //     "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
          //   },
          //   success: (data) => {
          //     console.log("success data", data)
          //     document.location.href = "/users/sign_in"
          //   }
          // })
          $.ajax({
            method: "DELETE",
            url: "/session_timeout",
            dataType: "script",
            // contentType: "application/javascript",
            headers: {
              "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
            },
            success: (data) => {
              console.log("success data", data)
              // document.location.href = "/users/sign_in"
              document.location.href = "/"
            }
          })
        } else if (diffInMinutes <= 10) {
          jQuery("#timeoutModal").foundation("open")
          popup.open();
        }
      }, 10000);

      // Set ajax events
      $(document).on("ajax:complete", () => {
        console.log("TESTIAJAX COMPLETE")
        resetTimer();
      });

      $(document).ajaxComplete(function() {
        console.log("TESTIAJAX")
        resetTimer();
      });
    }
  })
})(window)

// $( document ).ajaxSend(function() {
//   // $( ".log" ).text( "Triggered ajaxSend handler." );
//   console.log("TESTIAJAX")
// });
