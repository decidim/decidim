import { Controller } from "@hotwired/stimulus"

/**
 * This controller is used to show the offline banner on top of the page when the user
 * loses network connectivity. It is bound to the `.js-offline-message` element and, on
 * connect (which runs on the initial load and on every Turbo navigation), shows the banner
 * only when the browser reports being offline AND the offline fallback page is not being
 * displayed (i.e. there is no `#offline-fallback-html` element on the page).
 */
export default class OfflineBannerController extends Controller {
  connect() {
    // show the banner if it is offline AND the offline-fallback is not displaying
    if (!navigator.onLine && !document.querySelector("#offline-fallback-html")) {
      this.element.style.display = "block";
    }
  }
}
