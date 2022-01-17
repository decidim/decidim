// check if the browser supports serviceWorker at all
window.addEventListener("load", async () => {
  if ("serviceWorker" in navigator) {
    // eslint-disable-next-line no-unused-vars
    const registration = await navigator.serviceWorker.register("/sw.js", { scope: "/" });

    // NOTE: Uncomment this when enable PUSH notifications
    // const permission = await window.Notification.requestPermission();

    // if (permission !== "granted") {
    //   throw new Error("Permission not granted for Notification");
    // }

    // do stuff
  } else {
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});

// Visits control to prompt the a2hs confirmation banner
let visits = localStorage.getItem("visits_counter") || 0
let visitsReached = false;

window.addEventListener("beforeinstallprompt", (event) => {
  localStorage.setItem("visits_counter", parseInt(visits) + 1)
  console.log("---> ");
  window.deferredPrompt = event;

  if(visits > 3)
    visitsReached = true
  else
    event.preventDefault();

  console.log(`'beforeinstallprompt' event was fired.`);
});

$( document ).ready(function() {
  window.addEventListener("appinstalled", () => {
    localStorage.removeItem("visits_counter");
    console.log("PWA was installed");
  });

  window.addEventListener('touchend', async () => {
    if(visitsReached === true) {
      console.log('👍', 'butInstall-clicked');
      const promptEvent = window.deferredPrompt;
      if (!promptEvent) {
        // The deferred prompt isn't available.
        return;
      }
      promptEvent.prompt();
      window.deferredPrompt = null;
    }
  });
});
