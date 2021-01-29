// = require foundation

((exports) => {
  exports.$(() => {
    const Foundation = exports.Foundation;
    const $myModal = jQuery("#timeoutModal")
    const sessionTime = $myModal.attr("data-session-timeout")
    const endsAt = exports.moment().add(sessionTime, "seconds")
    console.log("sessionTime:", sessionTime)
    const popup = new Foundation.Reveal($myModal);
    const $continueSessionButton = $("#continueSession")

    $continueSessionButton.on("click", () => {
      console.log("CLICK")
    })

    setInterval(() => {
      const diff = endsAt - exports.moment();
      const diffInMinutes = Math.round(diff / 60000);

      console.log("diffInMinutes", diffInMinutes)
      console.log("ready", $myModal[0])

      if (diffInMinutes <= 2) {
        jQuery("#timeoutModal").foundation("open")
        popup.open();
      }
    }, 10000);
  })
})(window)
