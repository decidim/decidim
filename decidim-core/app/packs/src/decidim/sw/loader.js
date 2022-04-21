// check if the browser supports serviceWorker at all
window.addEventListener("load", async () => {
  if ("serviceWorker" in navigator) {
    await navigator.serviceWorker.register("/sw.js", { scope: "/" });
    const mandatoryElements = document.querySelector(".js-sw-mandatory");

    if (mandatoryElements) {
      mandatoryElements.style.display = "block";
    }
  } else {
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});

