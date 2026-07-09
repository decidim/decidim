/**
 * Shows the offline banner (`.js-offline-message`, rendered by the
 * `_offline_banner.html.erb` layout partial) when the browser reports being
 * offline and the offline fallback page (`#offline-fallback-html`) is not
 * being displayed, and hides it again otherwise.
 */

document.addEventListener("turbo:load", () => {
  const banner = document.querySelector(".js-offline-message");
  if (!banner) {
    return;
  }

  if (!navigator.onLine && !document.querySelector("#offline-fallback-html")) {
    banner.style.display = "block";
  } else {
    banner.style.display = "";
  }
});
