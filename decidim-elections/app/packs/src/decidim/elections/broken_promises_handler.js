/* Fallback for non-handled failed promises */
window.addEventListener("unhandledrejection", (event) => {
  if (window.Decidim.currentDialogs["server-failure"]) {
    document.getElementById("tech-info").innerHTML = event.reason

    if (event.reason.toString().indexOf("fetch") === -1) {
      document.getElementById("communication_error").hidden = true
      document.getElementById("generic_error").hidden = false
    }

    window.Decidim.currentDialogs["server-failure"].open()
  }
});
