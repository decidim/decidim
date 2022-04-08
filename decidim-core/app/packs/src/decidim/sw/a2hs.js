const visitedPages = JSON.parse(sessionStorage.getItem("visitedPages")) || []
const DELAYED_VISITS = 2
let deferredPrompt = null

const shouldCountVisitedPages = () => sessionStorage.getItem("userChoice") !== "dismissed" && visitedPages.length < DELAYED_VISITS && !visitedPages.includes(location.pathname)
const shouldPrompt = () => deferredPrompt && sessionStorage.getItem("userChoice") !== "dismissed" && visitedPages.length >= DELAYED_VISITS

window.addEventListener("beforeinstallprompt", (event) => {
  deferredPrompt = event

  // allow the user browse through different locations before prompt them anything
  if (shouldCountVisitedPages()) {
    sessionStorage.setItem("visitedPages", JSON.stringify([...visitedPages, location.pathname]))
  }
});

// to trigger the prompt, it must be a "user gesture"
window.addEventListener("click", async (event) => {
  if (shouldPrompt()) {
    event.preventDefault()
    deferredPrompt.prompt()

    const { outcome } = await deferredPrompt.userChoice;
    // store the user choice to avoid asking again in the current session
    sessionStorage.setItem("userChoice", outcome)
    sessionStorage.removeItem("visitedPages")
  }
});
