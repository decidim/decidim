import UploadModal from "src/decidim/direct_uploads/upload_modal";
import { truncateFilename } from "src/decidim/direct_uploads/upload_utility";
import { escapeHtml, escapeQuotes } from "src/decidim/utilities/text";

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
  const previousId = Array.from(files.querySelectorAll("[type=hidden][id]"))
  const isMultiple = modal.options.multiple
  const isTitled = modal.options.titled

  // fastest way to clean children nodes
  files.textContent = ""

  // divide the items between those will gonna be removed, and added
  const [removeFiles, addFiles] = [modal.items.filter(({ removable }) => removable), modal.items.filter(({ removable }) => !removable)]

  addFiles.forEach((file, ix) => {
    let title = truncateFilename(file.name, 19)

    let hidden = ""
    if (file.hiddenField) {
      // if there is hiddenField, this file is new
      let fileField = null;
      if (isMultiple) {
        fileField = `${modal.options.resourceName}[${modal.options.addAttribute}][${ix}][file]`
      } else if (isTitled) {
        fileField = `${modal.options.resourceName}[${modal.options.addAttribute}][file]`
      } else {
        fileField = `${modal.options.resourceName}[${modal.options.addAttribute}]`;
      }

      hidden = `<input type="hidden" name="${fileField}" value="${file.hiddenField}" />`
    } else {
      // otherwise, we keep the attachmentId
      let fileField = null;
      if (isMultiple) {
        fileField = `${modal.options.resourceName}[${modal.options.addAttribute}][${ix}][id]`;
      } else if (isTitled) {
        fileField = `${modal.options.resourceName}[${modal.options.addAttribute}][id]`;
      } else {
        fileField = `${modal.options.resourceName}[${modal.options.addAttribute}]`;
      }

      // convert all node attributes to string
      const attributes = Array.from(previousId.find(({ id }) => id === file.attachmentId).attributes).reduce((acc, { name, value }) => `${acc} ${name}="${value}"`, "")
      hidden = `<input ${attributes} />`
      hidden += `<input type="hidden" name="${fileField}" value="${file.attachmentId}" />`
    }

    if (isTitled) {
      const titleValue = modal.modal.querySelectorAll('input[type="text"]')[ix].value
      // NOTE - Renaming the attachment is not supported when multiple uploader is disabled
      const titleField = isMultiple
        ? `${modal.options.resourceName}[${modal.options.addAttribute}][${ix}][title]`
        : `${modal.options.resourceName}[${modal.options.addAttribute}][title]`
      hidden += `<input type="hidden" name="${titleField}" value="${escapeQuotes(titleValue)}" />`

      title = titleValue
    }

    const attachmentIdOrHiddenField = file.attachmentId
      ? `data-attachment-id="${file.attachmentId}"`
      : `data-hidden-field="${file.hiddenField}"`

    const template = `
      <div ${attachmentIdOrHiddenField} data-filename="${escapeQuotes(file.name)}" data-title="${escapeQuotes(title)}">
        ${(/image/).test(file.type) && "<div><img src=\"data:,\" role=\"presentation\" /></div>" || ""}
        <span>${escapeHtml(title)} (${escapeHtml(truncateFilename(file.name))})</span>
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

    // update the modal title if there are files uploaded and load files (if previously deleted after clicking cancel)
    modal.button.addEventListener("click", (event) => event.preventDefault() || (modal.items.length === 0 && [...files.children].forEach((child) => child.tagName === "DIV" && modal.preloadFiles(child))) || updateModalTitle(modal));

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
