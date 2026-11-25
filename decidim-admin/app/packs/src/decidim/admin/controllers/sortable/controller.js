import { Controller } from "@hotwired/stimulus"

/**
 * This controller keeps the hidden position inputs of a sortable list in sync with the DOM order.
 * It sits on the sortable container and is triggered by the `sortupdate` event that html5sortable
 * dispatches when a drag ends, renumbering the `input.position` field of each item.
 */
export default class extends Controller {
  update() {
    this.element.querySelectorAll(":scope > li").forEach((item, index) => {
      const input = item.querySelector("input.position")

      if (!input) {
        return
      }

      input.value = index + 1
    })
  }
}
