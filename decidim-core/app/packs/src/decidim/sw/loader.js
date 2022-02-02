// check if the browser supports serviceWorker at all
window.addEventListener("load", async () => {
  if ("serviceWorker" in navigator) {
    const vapidPublicKeyElement = JSON.parse(document.querySelector("#vapidPublicKey").value)
    const registration = await navigator.serviceWorker.register("/sw.js", { scope: "/" });
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: new Uint8Array(vapidPublicKeyElement)
    });

    await fetch("/subscribe_to_notifications", {
      headers: { "Content-Type": "application/json" },
      method: "POST",
      body: JSON.stringify(subscription)
    });
  } else {
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});
