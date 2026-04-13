import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  sort() {
    const activeBlocks = Array.from(this.element.querySelectorAll(".js-list-actives li"));
    const activeBlocksId = activeBlocks.map((block) => block.dataset.contentBlockId);
    const sortUrl = this.element.querySelector(".js-list-actives").dataset.sortUrl;
    const token = document.querySelector("meta[name='csrf-token']");

    fetch(sortUrl, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token && token.getAttribute("content")
      },
      body: JSON.stringify({ ids_order: activeBlocksId }) // eslint-disable-line camelcase
    });
  }
}
