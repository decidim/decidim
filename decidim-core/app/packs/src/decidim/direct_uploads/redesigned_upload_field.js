import UploadModal from "src/decidim/direct_uploads/redesigned_upload_modal";
import { truncateFilename } from "src/decidim/direct_uploads/upload_utility";

const updateModalTitle = (modal) => {
  if (modal.uploadItems.children.length === 0) {
    modal.modalTitle.innerHTML = modal.modalTitle.dataset.addlabel;
  } else {
    modal.modalTitle.innerHTML = modal.modalTitle.dataset.editlabel;
  }
  modal.updateDropZone();
}

const updateActiveUploads = (modal) => {
  // remove the default image block, if exists
  const defaultFile = document.getElementById(`default-active-${modal.modal.id}`)
  if (defaultFile) {
    defaultFile.remove()
  }

  const files = document.querySelector(`[data-active-uploads=${modal.modal.id}]`)

  // fastest way to clean children nodes
  files.textContent = ""

  // divide the items between those'll gonna be removed, and added
  const [removeFiles, addFiles] = [modal.items.filter(({ removable }) => removable), modal.items.filter(({ removable }) => !removable)]

  addFiles.forEach((file) => {
    let title = truncateFilename(file.name, 19)

    let hidden = `<input type="hidden" name="${file.hiddenField.name}" value="${file.hiddenField.value}" />`
    if (modal.options.titled) {
      const value = modal.modal.querySelector('input[type="text"]').value
      title = `${value} (${truncateFilename(file.name)})`
      hidden += `<input type="hidden" name="${file.hiddenTitle.name}" value="${value}" />`
    }

    const template = `
      <div data-filename="${file.name}" data-title="${title}">
        <div><img src="" alt="${file.name}" /></div>
        <span>${title}</span>
        ${hidden}
      </div>
    `

    const div = document.createElement("div")
    div.innerHTML = template.trim()

    const container = div.firstChild

    modal.autoloadImage(container, file)

    files.appendChild(container)
  });

  removeFiles.forEach(() => {
    const div = document.createElement("div")
    div.innerHTML = `<input name='${modal.options.resourceName}[remove_${modal.button.name}]' type="hidden" value="true">`
    files.appendChild(div.firstChild)
  })

  modal.updateAddAttachmentsButton();
}

const highlightDropzone = (modal) => {
  modal.emptyItems.classList.add("is-dragover")
  modal.uploadItems.classList.add("is-dragover")
}

const resetDropzone = (modal) => {
  modal.emptyItems.classList.remove("is-dragover")
  modal.uploadItems.classList.remove("is-dragover")
}

/* NOTE: all this actions are supposed to work using the modal object,
  so, perhaps, it would be more accurate to move all the inner listeners to the UploadModal class */
document.addEventListener("DOMContentLoaded", () => {
  const attachmentButtons = document.querySelectorAll("button[data-upload]");

  attachmentButtons.forEach((attachmentButton) => {
    const modal = new UploadModal(attachmentButton);

    // append to the modal items array those files already validated (only in first pageload)
    const files = document.querySelector(`[data-active-uploads=${modal.modal.id}]`);
    [...files.children].forEach((child) => modal.preloadFiles(child));

    // whenever the input fields changes, process the files
    modal.input.addEventListener("change", (event) => modal.uploadFiles(event.target.files));

    // update the modal title if there are files uploaded
    modal.button.addEventListener("click", (event) => event.preventDefault() || updateModalTitle(modal));

    // avoid browser to open the file
    modal.dropZone.addEventListener("dragover", (event) => event.preventDefault() || highlightDropzone(modal));
    modal.dropZone.addEventListener("dragleave", () => resetDropzone(modal));
    // avoid browser to open the file and then, process the files
    modal.dropZone.addEventListener("drop", (event) => event.preventDefault() || resetDropzone(modal) || modal.uploadFiles(event.dataTransfer.files));

    // update the DOM with the validated items from the modal
    modal.saveButton.addEventListener("click", (event) => event.preventDefault() || updateActiveUploads(modal));
    // remove the uploaded files if cancel button is clicked
    modal.cancelButton.addEventListener("click", (event) => event.preventDefault() || modal.cleanAllFiles());
  })
})
