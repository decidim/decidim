// check if the browser supports serviceWorker at all
window.addEventListener("load", async () => {
  if ("serviceWorker" in navigator) {
    const mandatoryElements = document.querySelector(".sw-mandatory")

    if (mandatoryElements) {
      mandatoryElements.style.display = "block";
    }

    await navigator.serviceWorker.register("/sw.js", { scope: "/" });
  } else {
    console.log("Your browser doesn't support service workers 🤷‍♀️");
  }
});

