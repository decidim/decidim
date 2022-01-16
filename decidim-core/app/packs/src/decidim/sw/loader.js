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
window.addEventListener("beforeinstallprompt", (e) => {
  let visits = localStorage.getItem("visits_counter") || 0
  localStorage.setItem("visits_counter", parseInt(visits) + 1)
  console.log("---> ");

  if(visits > 3)
    e.prompt();
  else
    e.preventDefault();

  console.log(`'beforeinstallprompt' event was fired.`);
});

window.addEventListener("appinstalled", () => {
  localStorage.removeItem("visits_counter");
  console.log("PWA was installed");
});
