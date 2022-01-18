// check if the browser supports serviceWorker at all
window.addEventListener("load", async () => {
  if ("serviceWorker" in navigator) {
    await navigator.serviceWorker.register("/sw.js", { scope: "/" });
  } else {
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});

// Visits control to prompt the a2hs confirmation banner
let visits = localStorage.getItem("visits_counter") || 0
let visitsReached = false;

window.addEventListener("beforeinstallprompt", (event) => {
  localStorage.setItem("visits_counter", parseInt(visits, 10) + 1)
  window.deferredPrompt = event;

  if (visits > 3)
  {visitsReached = true}
  else
  {event.preventDefault();}

});

$(document).ready(function() {
  window.addEventListener("appinstalled", () => {
    localStorage.removeItem("visits_counter");
    console.log("PWA was installed");
  });

  window.addEventListener("touchend", async () => {
    if (visitsReached === true) {
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
