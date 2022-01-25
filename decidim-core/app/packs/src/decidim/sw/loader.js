// check if the browser supports serviceWorker at all
window.addEventListener("load", async () => {
  if ("serviceWorker" in navigator) {
    // eslint-disable-next-line no-unused-vars
    const registration = await navigator.serviceWorker.register("/sw.js", { scope: "/" });
  } else {
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});
