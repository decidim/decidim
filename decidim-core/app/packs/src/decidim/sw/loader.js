// check if the browser supports serviceWorker at all
window.addEventListener("load", async () => {
  if ("serviceWorker" in navigator) {
    await navigator.serviceWorker.register("/sw.js", { scope: "/" });

    const mandatoryElements = document.querySelector(".js-sw-mandatory");
    // Opera uses Opera for versions <= 12 and OPR for versions > 12
    const isOperaMini =
      ((navigator.userAgent.indexOf("OPR") > -1) || (navigator.userAgent.indexOf("Opera") > -1)) &&
      (navigator.userAgent.indexOf("Mini") > -1);

    if (mandatoryElements && isOperaMini) {
      mandatoryElements.classList.add("hide")
    }
  } else {
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});
