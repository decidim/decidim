/**
 * Shows the offline banner on top of the page when the user loses network
 * connectivity. The banner (`.js-offline-message`) is only shown when the
 * browser reports being offline AND the offline fallback page is not being
 * displayed (i.e. there is no `#offline-fallback-html` element on the page).
 *
 * This previously lived as an inline script in the `_offline_banner.html.erb`
 * layout partial. It was moved here (loaded by the `decidim_core` entrypoint,
 * present in all layout contexts) to allow removing `unsafe-inline` from the
 * CSP `script-src`.
 *
 * The check runs on `turbo:load` so it happens on the initial load and on every
 * Turbo navigation, matching the original render-time ordering.
 *
 * The `.js-offline-message` element is only rendered by the
 * `_offline_banner.html.erb` partial, so its absence is the signal to do
 * nothing, mirroring the original script that only ran inside that partial.
 */

document.addEventListener("turbo:load", () => {
  // show the banner if it is offline AND the offline-fallback is not displaying
  if (!navigator.onLine && !document.querySelector("#offline-fallback-html")) {
    const banner = document.querySelector(".js-offline-message");
    if (!banner) {
      return;
    }

    banner.style.display = "block";
  }
});
