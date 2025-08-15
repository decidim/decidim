import { Controller } from "@hotwired/stimulus"
import { EmojiButton } from "src/decidim/controllers/emoji/emoji"

export default class extends Controller {
  connect() {
    // Get current controllers
    let controllers = this.element.dataset.controller.split(" ");

    // Remove 'foo' controller
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
