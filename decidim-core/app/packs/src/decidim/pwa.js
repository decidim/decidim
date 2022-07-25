window.addEventListener("beforeinstallprompt", (ev) => {
  // Disable the application install prompt showing constantly. This event is
  // not a standard event but it fixes the issue where it exists, i.e. Chrome.
  if (localStorage.getItem("pwaInstallPromptSeen")) {
    ev.preventDefault();
  } else {
    localStorage.setItem("pwaInstallPromptSeen", true);
  }
});
