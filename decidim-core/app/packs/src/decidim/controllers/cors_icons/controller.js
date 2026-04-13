import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const iconsPath = window.Decidim.config.get("icons_path");
    if (!iconsPath) {
      return;
    }

    fetch(iconsPath).
      then((response) => response.text()).
      then((svgText) => {
        this.element.innerHTML = svgText;
        document.body.insertBefore(this.element, document.body.childNodes[0]);
      });
  }
}
