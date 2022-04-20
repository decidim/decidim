// check if the browser supports serviceWorker at all
window.addEventListener("load", () => {
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("/sw.js", { scope: "/" });
  } else {
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});
