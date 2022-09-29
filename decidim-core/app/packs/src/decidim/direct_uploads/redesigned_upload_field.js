import UploadModal from "src/decidim/direct_uploads/redesigned_upload_modal";
import { truncateFilename } from "src/decidim/direct_uploads/upload_utility";

const addButtonEventListener = (modal) => {
  modal.button.addEventListener("click", (event) => {
    event.preventDefault();

    if (modal.uploadItems.children.length === 0) {
      modal.modalTitle.innerHTML = modal.modalTitle.dataset.addlabel;
    } else {
      modal.modalTitle.innerHTML = modal.modalTitle.dataset.editlabel;
    }
    modal.updateDropZone();
  })
}

document.addEventListener("DOMContentLoaded", () => {
  const attachmentButtons = document.querySelectorAll("button[data-upload]");

  attachmentButtons.forEach((attachmentButton) => {
    const modal = new UploadModal(attachmentButton);

    // mark as validated the files already test it
    modal.items.forEach((child) => modal.createUploadItem(child, []))

    // whenever the input fields changes, process the files
    modal.input.addEventListener("change", (event) => Array.from(event.target.files).forEach((file) => modal.uploadFile(file)))

    addButtonEventListener(modal);

    // avoid browser to open the file
    modal.dropZone.addEventListener("dragover", (event) => event.preventDefault())
    // avoid browser to open the file and then, process the files
    modal.dropZone.addEventListener("drop", (event) => event.preventDefault() || Array.from(event.dataTransfer.files).forEach((file) => modal.uploadFile(file)))

    // update the DOM with the validated items from the modal
    modal.saveButton.addEventListener("click", (event) => {
      event.preventDefault();

      const files = document.querySelector("[data-active-uploads]")

      modal.items.forEach((item) => {
        let title = truncateFilename(item.name, 19)

        let hidden = `<input type="hidden" name="${item.hiddenField.name}" value="${item.hiddenField.value}" />`
        if (modal.options.titled) {
          const value = modal.modal.querySelector('input[type="text"]').value
          title = `${value} (${truncateFilename(item.name)})`
          hidden += `<input type="hidden" name="${item.hiddenTitle.name}" value="${value}" />`
        }

        const template = `
          <div data-filename="${item.name}" data-title="${title}">
            <div><img src="" alt="${item.name}" /></div>
            <span>${title}</span>
            ${hidden}
          </div>
        `

        const div = document.createElement("div")
        div.innerHTML = template.trim()

        const container = div.firstChild

        // autoload the image
        const reader = new FileReader();
        reader.readAsDataURL(item);
        reader.onload = ({ target: { result }}) => {
          const img = container.querySelector("img")
          img.src = result
        }

        files.appendChild(container)
      });

      modal.updateAddAttachmentsButton();
    });
  })
})
