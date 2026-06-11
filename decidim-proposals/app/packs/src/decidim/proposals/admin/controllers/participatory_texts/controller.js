import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller for the admin participatory text drafts form.
 *
 * The form lists every draft proposal as a sortable accordion item and offers
 * a "Save draft" button besides the regular "Publish document" submit.
 *
 * - Saving a draft submits the form natively, so the HTML validations are
 *   skipped (drafts may still have incomplete required fields) and a
 *   `save_draft` flag travels as a hidden input, since not all browsers
 *   submit the clicked button as form data.
 * - When the list is reordered (html5sortable's `sortupdate` event), the
 *   hidden position field of every draft is renumbered to match the new
 *   order.
 *
 * Targets:
 *   - `list` – The sortable `<ul>` containing one `<li>` per draft proposal.
 */
export default class ParticipatoryTextsController extends Controller {

  /**
   * Appends a hidden `save_draft` input to the form and submits it natively.
   * @param {Event} event - The click event fired by the "Save draft" button.
   * @returns {void}
   */
  saveDraft(event) {
    event.preventDefault();

    const hiddenInput = document.createElement("input");
    hiddenInput.type = "hidden";
    hiddenInput.name = "save_draft";
    hiddenInput.value = "true";
    this.element.appendChild(hiddenInput);
    this.element.submit();
  }

  /**
   * Renumbers the hidden position field of every draft following the current
   * order of the list items.
   * @returns {void}
   */
  updatePositions() {
    this.listTarget.querySelectorAll("li").forEach((item, index) => {
      const positionInput = item.querySelector("input.position");
      if (positionInput) {
        positionInput.value = index + 1;
      }
    });
  }
}

ParticipatoryTextsController.targets = ["list"]
