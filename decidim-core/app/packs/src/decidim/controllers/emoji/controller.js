import { Controller } from "@hotwired/stimulus"
import { EmojiButton } from "src/decidim/controllers/emoji/emoji"

export default class extends Controller {

  /**
   * There is a problem that I could not identify here, but it seems that if we do not remove the emoji controller
   * from an element, we will have an endless load of the emoji object. Therefore, we are filtering through the existing
   *  controllers and removing the emoji. If there is no other element, we remove the data-attribute.
   * @returns {void}
   */
  connect() {
    let controllers = this.element.dataset.controller.split(" ");

    controllers = controllers.filter((controller) => controller !== "emoji");

    // Update the attribute
    if (controllers.length > 0) {
      this.element.setAttribute("data-controller", controllers.join(" "));
    } else {
      this.element.removeAttribute("data-controller");
    }

    this.emoji = new EmojiButton(this.element)
  }
}
