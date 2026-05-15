import { Controller } from "@hotwired/stimulus"

/**
 * DeleteAccount class handles the delete account functionality.
 * Since the delete account has a modal to confirm it, we need to copy the content of the
 * reason field to the hidden field in the form inside the modal.
 */
export default class extends Controller {
  connect() {
    this.deleteAccountModalForm = document.querySelector(".delete-account-modal");
    this.openModalButton = document.querySelector(".open-modal-button");

    this.bindEvents();
  }

  disconnect() {
    if (this.boundModalOpen) {
      this.openModalButton.removeEventListener("click", this.boundModalOpen)
    }
  }

  bindEvents() {
    if (this.openModalButton) {
      this.boundModalOpen = this.handleModalOpen.bind(this)
      this.openModalButton.addEventListener("click", this.boundModalOpen);
    }
  }

  handleModalOpen(event) {
    try {
      const reasonTextarea = this.element.querySelector('[name="delete_account[delete_reason]"]');
      const reasonInput = this.deleteAccountModalForm.querySelector('[name="delete_account[delete_reason]"]');

      if (reasonTextarea && reasonInput) {
        reasonInput.value = reasonTextarea.value;
      }
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    event.preventDefault();
    event.stopPropagation();
    return false;
  }
}
