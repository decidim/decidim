document.addEventListener("DOMContentLoaded", () => {
  const preventTimeoutDiv = document.querySelector("div.timeout-prevention");
  if (!preventTimeoutDiv) {
    return;
  }

  const preventTimeOut = (seconds) => {
    const timeoutModal = document.querySelector("#timeoutModal");
    const interval = Number(timeoutModal.dataset.sessionTimeoutInterval);
    const initialHeartBeatInterval = parseInt(timeoutModal.dataset.sessionTimeout, 10) * 500;
    const csrfToken = document.querySelector("meta[name=csrf-token]").attributes.getNamedItem("content").value

    let heartBeatInterval = initialHeartBeatInterval;
    let preventTimeOutSeconds = seconds;
    const heartbeathPath = timeoutModal.dataset.heartbeatPath;

    const exitInterval = setInterval(() => {
      if (preventTimeOutSeconds > 0) {
        preventTimeOutSeconds -= interval;
        heartBeatInterval -= interval;
        if (heartBeatInterval <= 0) {
          fetch(heartbeathPath, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": csrfToken
            }
          })
          heartBeatInterval = initialHeartBeatInterval;
        }
      } else {
        clearInterval(exitInterval);
      }
    }, interval)


    window.addEventListener("beforeunload", () => {
      clearInterval(exitInterval);
      return;
    });
  }

  preventTimeOut(Number(preventTimeoutDiv.dataset.meetingSecondsLeft));
})
