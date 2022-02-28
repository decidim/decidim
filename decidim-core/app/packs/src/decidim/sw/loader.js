// check if the browser supports serviceWorker at all
window.addEventListener("load", async () => {
  if ("serviceWorker" in navigator) {
    const registration = await navigator.serviceWorker.register("/sw.js", { scope: "/" });

    if (registration && Notification.permission === "granted") {
      const vapidElement = document.querySelector("#vapidPublicKey")
      // element could not exist in DOM
      if (vapidElement) {
        const vapidPublicKeyElement = JSON.parse(vapidElement.value)
        const subscription = await registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: new Uint8Array(vapidPublicKeyElement)
        });

        if (subscription) {
          await fetch("/subscribe_to_notifications", {
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
            },
            method: "POST",
            body: JSON.stringify(subscription)
          });
        }
      }
    }
  } else {
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});
