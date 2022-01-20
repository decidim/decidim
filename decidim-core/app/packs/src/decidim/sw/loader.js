function removeNotAllowedSettings () {
  $(".push-notifications").remove();
}

function displayAllowedSettings () {
  $(".push-notifications").removeClass("hide")
}

function toggleNotificationsReminder () {
  if (Notification.permission === 'granted') {
    $(".push-notifications__reminder").addClass("hide")
  }else{
    $(".push-notifications__reminder").removeClass("hide")
  }
}

$(document).ready(function() {
  $("#user_allow_push_notifications").on("change", function () {
    if(this.checked && ("serviceWorker" in navigator)) {
      Notification.requestPermission(async (permission) => {
        toggleNotificationsReminder()
      });
    }
  });
});


// check if the browser supports serviceWorker at all
window.addEventListener("load", async () => {
  if ("serviceWorker" in navigator) {
    // eslint-disable-next-line no-unused-vars
    toggleNotificationsReminder();
    displayAllowedSettings();
    const registration = await navigator.serviceWorker.register("/sw.js", { scope: "/" });
  } else {
    removeNotAllowedSettings();
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});
